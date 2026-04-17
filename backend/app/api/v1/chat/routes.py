"""Chat API routes — Conversations, Messages, Streaming, Agent Reasoning."""

import json
import logging
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc, func

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.conversation import Conversation
from app.models.message import Message
from app.models.agent_run import AgentRun, AgentStep
from app.schemas.api import (
    CreateConversationRequest,
    ConversationResponse,
    UpdateConversationRequest,
    SendMessageRequest,
    MessageResponse,
    ConversationDetailResponse,
    ReasoningSummaryResponse,
    AgentStepSummary,
)
from app.services.orchestration.pipeline import OrchestrationPipeline

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/conversations", response_model=ConversationResponse, status_code=201)
async def create_conversation(
    req: CreateConversationRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    conversation = Conversation(
        user_id=user.id,
        mode=req.mode,
    )
    db.add(conversation)
    await db.flush()
    return conversation


@router.get("/conversations", response_model=list[ConversationResponse])
async def list_conversations(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    archived: bool = False,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    query = (
        select(Conversation)
        .where(Conversation.user_id == user.id)
        .where(Conversation.is_archived == archived)
        .order_by(desc(Conversation.updated_at))
        .offset(skip)
        .limit(limit)
    )
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/conversations/{conversation_id}", response_model=ConversationDetailResponse)
async def get_conversation(
    conversation_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Conversation)
        .where(Conversation.id == conversation_id)
        .where(Conversation.user_id == user.id)
    )
    conversation = result.scalar_one_or_none()
    if not conversation:
        raise HTTPException(status_code=404, detail="Konversation nicht gefunden")

    messages_result = await db.execute(
        select(Message)
        .where(Message.conversation_id == conversation_id)
        .order_by(Message.created_at)
    )
    messages = messages_result.scalars().all()

    return ConversationDetailResponse(
        conversation=ConversationResponse.model_validate(conversation),
        messages=[MessageResponse.model_validate(m) for m in messages],
    )


@router.patch("/conversations/{conversation_id}", response_model=ConversationResponse)
async def update_conversation(
    conversation_id: str,
    req: UpdateConversationRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Conversation)
        .where(Conversation.id == conversation_id)
        .where(Conversation.user_id == user.id)
    )
    conversation = result.scalar_one_or_none()
    if not conversation:
        raise HTTPException(status_code=404, detail="Konversation nicht gefunden")

    if req.title is not None:
        conversation.title = req.title
    if req.is_archived is not None:
        conversation.is_archived = req.is_archived
    if req.is_pinned is not None:
        conversation.is_pinned = req.is_pinned

    return conversation


@router.delete("/conversations/{conversation_id}", status_code=204)
async def delete_conversation(
    conversation_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Conversation)
        .where(Conversation.id == conversation_id)
        .where(Conversation.user_id == user.id)
    )
    conversation = result.scalar_one_or_none()
    if not conversation:
        raise HTTPException(status_code=404, detail="Konversation nicht gefunden")

    await db.delete(conversation)
    return None


@router.post("/conversations/{conversation_id}/messages")
async def send_message(
    conversation_id: str,
    req: SendMessageRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Send a message and receive a streaming multi-agent response."""
    # Validate conversation ownership
    result = await db.execute(
        select(Conversation)
        .where(Conversation.id == conversation_id)
        .where(Conversation.user_id == user.id)
    )
    conversation = result.scalar_one_or_none()
    if not conversation:
        raise HTTPException(status_code=404, detail="Konversation nicht gefunden")

    # Validate mode access (basic check — full check in usage service)
    if req.mode not in ("fast", "smart", "deep"):
        raise HTTPException(status_code=400, detail="Ungültiger Modus")

    # Input validation
    if not req.content.strip():
        raise HTTPException(status_code=400, detail="Nachricht darf nicht leer sein")
    if len(req.content) > 32000:
        raise HTTPException(status_code=400, detail="Nachricht zu lang (max. 32.000 Zeichen)")

    # Save user message
    user_message = Message(
        conversation_id=conversation_id,
        role="user",
        content=req.content,
        mode=req.mode,
    )
    db.add(user_message)
    await db.flush()

    # Auto-title on first message
    if conversation.message_count == 0:
        title = req.content[:80].strip()
        if len(req.content) > 80:
            title += "…"
        conversation.title = title

    conversation.message_count += 1
    conversation.last_message_at = datetime.now(timezone.utc)
    conversation.mode = req.mode

    # Build conversation context (last N messages)
    prev_messages_result = await db.execute(
        select(Message)
        .where(Message.conversation_id == conversation_id)
        .order_by(desc(Message.created_at))
        .limit(20)
    )
    conversation_history = prev_messages_result.scalars().all()

    # Format context for the orchestration
    context_parts = []
    for msg in reversed(conversation_history[1:]):  # Exclude current message
        context_parts.append(f"{'User' if msg.role == 'user' else 'Assistant'}: {msg.content}")

    full_prompt = req.content
    if context_parts:
        context_str = "\n".join(context_parts[-10:])  # Last 10 messages for context
        full_prompt = f"Conversation context:\n{context_str}\n\nCurrent user message: {req.content}"

    # Execute orchestration with streaming
    pipeline = OrchestrationPipeline(db=db, mode=req.mode)

    async def event_stream():
        full_content = ""
        reasoning_summary = None

        try:
            async for event in pipeline.execute_streaming(full_prompt):
                if event["type"] == "token":
                    full_content += event["content"]
                    yield f"data: {json.dumps(event)}\n\n"
                elif event["type"] == "complete":
                    reasoning_summary = event.get("reasoning_summary")
                    yield f"data: {json.dumps(event)}\n\n"
                else:
                    yield f"data: {json.dumps(event)}\n\n"

        except Exception as e:
            logger.error(f"Orchestration error: {e}")
            yield f"data: {json.dumps({'type': 'error', 'message': 'Ein Fehler ist aufgetreten'})}\n\n"
            full_content = "Es tut mir leid, bei der Verarbeitung Ihrer Anfrage ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut."

        # Save assistant message
        assistant_message = Message(
            conversation_id=conversation_id,
            role="assistant",
            content=full_content,
            mode=req.mode,
            tokens_input=pipeline.total_tokens // 2,  # Approximate split
            tokens_output=pipeline.total_tokens // 2,
            cost_usd=pipeline.total_cost,
            latency_ms=pipeline.total_latency,
            reasoning_summary=reasoning_summary,
        )
        db.add(assistant_message)
        conversation.message_count += 1
        await db.commit()

        yield "data: [DONE]\n\n"

    return StreamingResponse(
        event_stream(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@router.get(
    "/conversations/{conversation_id}/reasoning/{message_id}",
    response_model=ReasoningSummaryResponse,
)
async def get_reasoning(
    conversation_id: str,
    message_id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Get the sanitized agent reasoning summary for a message."""
    result = await db.execute(
        select(Message)
        .where(Message.id == message_id)
        .where(Message.conversation_id == conversation_id)
    )
    message = result.scalar_one_or_none()
    if not message:
        raise HTTPException(status_code=404, detail="Nachricht nicht gefunden")

    # Verify conversation ownership
    conv_result = await db.execute(
        select(Conversation)
        .where(Conversation.id == conversation_id)
        .where(Conversation.user_id == user.id)
    )
    if not conv_result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Konversation nicht gefunden")

    if not message.reasoning_summary:
        raise HTTPException(status_code=404, detail="Keine Denkprozess-Daten verfügbar")

    summary = message.reasoning_summary
    return ReasoningSummaryResponse(
        mode=summary.get("mode", "smart"),
        task_type=summary.get("task_type"),
        total_latency_ms=message.latency_ms,
        refinement_passes=summary.get("refinement_passes", 0),
        steps=[
            AgentStepSummary(
                agent_role=step["agent"],
                summary=step.get("summary"),
                latency_ms=step.get("latency_ms", 0),
                sequence=i,
            )
            for i, step in enumerate(summary.get("steps", []))
        ],
    )
