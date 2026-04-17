import uuid
from datetime import datetime, timezone

from sqlalchemy import String, DateTime, Text, ForeignKey, Integer, Float, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base


class AgentRun(Base):
    """Tracks the full orchestration pipeline for a single message."""
    __tablename__ = "agent_runs"

    id: Mapped[str] = mapped_column(
        UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    message_id: Mapped[str] = mapped_column(
        UUID(as_uuid=False),
        ForeignKey("messages.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    mode: Mapped[str] = mapped_column(String(10), nullable=False)  # fast, smart, deep
    task_type: Mapped[str | None] = mapped_column(String(50), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="running")  # running, completed, failed
    total_tokens: Mapped[int] = mapped_column(Integer, default=0)
    total_cost_usd: Mapped[float] = mapped_column(Float, default=0.0)
    total_latency_ms: Mapped[int] = mapped_column(Integer, default=0)
    refinement_passes: Mapped[int] = mapped_column(Integer, default=0)

    # Timestamps
    started_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    # Relationships
    message = relationship("Message", back_populates="agent_run")
    steps = relationship("AgentStep", back_populates="agent_run", cascade="all, delete-orphan", order_by="AgentStep.sequence")


class AgentStep(Base):
    """Tracks individual agent contributions within a run."""
    __tablename__ = "agent_steps"

    id: Mapped[str] = mapped_column(
        UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    agent_run_id: Mapped[str] = mapped_column(
        UUID(as_uuid=False),
        ForeignKey("agent_runs.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    agent_role: Mapped[str] = mapped_column(String(50), nullable=False)
    # analyst, researcher, creative, critic, synthesizer, judge
    sequence: Mapped[int] = mapped_column(Integer, nullable=False)
    model_used: Mapped[str] = mapped_column(String(100), nullable=False)
    prompt: Mapped[str] = mapped_column(Text, nullable=False)  # Internal only, never exposed
    output: Mapped[str] = mapped_column(Text, nullable=False)  # Internal only
    summary: Mapped[str | None] = mapped_column(Text, nullable=True)  # Sanitized user-visible summary
    tokens_used: Mapped[int] = mapped_column(Integer, default=0)
    cost_usd: Mapped[float] = mapped_column(Float, default=0.0)
    latency_ms: Mapped[int] = mapped_column(Integer, default=0)
    status: Mapped[str] = mapped_column(String(20), default="completed")

    # Timestamps
    started_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    # Relationships
    agent_run = relationship("AgentRun", back_populates="steps")
