"""
Orka AI — Orchestration Pipeline

The heart of the multi-agent system. Coordinates agents, manages the pipeline,
tracks costs/tokens, and produces the final synthesized response.
"""

import time
import json
import asyncio
import logging
from typing import AsyncGenerator, Optional
from datetime import datetime, timezone

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.agent_run import AgentRun, AgentStep
from app.models.message import Message
from app.services.agents.definitions import (
    AgentRole,
    AGENT_CONFIGS,
    AGENT_SYSTEM_PROMPTS,
    MODE_PIPELINES,
    MAX_REFINEMENT_PASSES,
)
from app.services.agents.llm_provider import llm_provider, LLMResponse
from app.services.orchestration.task_classifier import classify_task, TASK_OUTPUT_STYLES

logger = logging.getLogger(__name__)


class OrchestrationPipeline:
    """Executes the multi-agent pipeline for a given user prompt."""

    def __init__(self, db: AsyncSession, mode: str = "smart"):
        self.db = db
        self.mode = mode
        self.pipeline = MODE_PIPELINES.get(mode, MODE_PIPELINES["smart"])
        self.context: dict[str, str] = {}  # Accumulated agent outputs
        self.total_tokens = 0
        self.total_cost = 0.0
        self.total_latency = 0
        self.steps: list[dict] = []

    def _get_model_for_mode(self, agent_role: AgentRole) -> str:
        """Select the appropriate model based on mode and agent role."""
        config = AGENT_CONFIGS[agent_role]
        if config.model_override:
            return config.model_override

        if self.mode == "fast":
            return settings.default_fast_model
        elif self.mode == "deep":
            # Use stronger model for synthesis and judgment in deep mode
            if agent_role in (AgentRole.SYNTHESIZER, AgentRole.JUDGE):
                return settings.default_deep_model
            return settings.default_smart_model
        else:  # smart
            return settings.default_smart_model

    def _build_agent_input(self, agent_role: AgentRole, user_prompt: str, task_type: str) -> str:
        """Build the input message for an agent, including accumulated context."""
        parts = [f"User prompt: {user_prompt}"]

        if task_type != "general":
            style = TASK_OUTPUT_STYLES.get(task_type, "")
            parts.append(f"Task type: {task_type}")
            parts.append(f"Output style guidance: {style}")

        # Feed accumulated context from previous agents
        for role_name, output in self.context.items():
            parts.append(f"\n--- {role_name.upper()} Output ---\n{output}")

        return "\n\n".join(parts)

    def _generate_step_summary(self, agent_role: AgentRole, output: str) -> str:
        """Generate a sanitized, user-friendly summary of what an agent did.
        NEVER expose internal prompts or raw reasoning to users."""
        summaries = {
            AgentRole.ANALYST: "Anfrage analysiert und Problem strukturiert",
            AgentRole.RESEARCHER: "Logische Pfade erkundet und Argumente recherchiert",
            AgentRole.CREATIVE: "Kreative Alternativen und neue Perspektiven generiert",
            AgentRole.CRITIC: "Schwächen identifiziert und Verbesserungen vorgeschlagen",
            AgentRole.SYNTHESIZER: "Beste Elemente kombiniert und finale Antwort erstellt",
            AgentRole.JUDGE: "Qualität bewertet und Antwort freigegeben",
        }
        return summaries.get(agent_role, "Verarbeitung abgeschlossen")

    async def _run_agent(
        self, agent_role: AgentRole, user_prompt: str, task_type: str
    ) -> LLMResponse:
        """Execute a single agent step."""
        config = AGENT_CONFIGS[agent_role]
        model = self._get_model_for_mode(agent_role)
        system_prompt = AGENT_SYSTEM_PROMPTS[agent_role]
        user_message = self._build_agent_input(agent_role, user_prompt, task_type)

        response = await llm_provider.complete(
            model=model,
            system_prompt=system_prompt,
            user_message=user_message,
            temperature=config.temperature,
            max_tokens=config.max_tokens,
            timeout_seconds=config.timeout_seconds,
        )

        # Accumulate context
        self.context[agent_role.value] = response.content
        self.total_tokens += response.tokens_input + response.tokens_output
        self.total_cost += response.cost_usd
        self.total_latency += response.latency_ms

        # Track step
        self.steps.append({
            "agent_role": agent_role.value,
            "model": model,
            "tokens": response.tokens_input + response.tokens_output,
            "cost": response.cost_usd,
            "latency_ms": response.latency_ms,
            "summary": self._generate_step_summary(agent_role, response.content),
            "output": response.content,  # Internal only
        })

        return response

    def _parse_judge_score(self, judge_output: str) -> tuple[float, bool, str]:
        """Parse the judge's evaluation output."""
        try:
            # Try to extract JSON scores from judge output
            lines = judge_output.split("\n")
            score_line = [l for l in lines if "overall_score" in l.lower()]
            approved_line = [l for l in lines if "approved" in l.lower()]

            overall_score = 7.0
            approved = True
            feedback = ""

            for line in lines:
                if "overall_score" in line.lower():
                    # Extract number
                    import re
                    numbers = re.findall(r"[\d.]+", line)
                    if numbers:
                        overall_score = float(numbers[0])
                if "approved" in line.lower() and "false" in line.lower():
                    approved = False
                if "feedback" in line.lower():
                    feedback = line.split(":", 1)[-1].strip() if ":" in line else ""

            return overall_score, approved, feedback
        except Exception:
            return 7.0, True, ""

    async def execute(self, user_prompt: str) -> dict:
        """Execute the full orchestration pipeline."""
        start_time = time.monotonic()

        # Classify task
        task_type = classify_task(user_prompt)
        logger.info(f"Task classified as: {task_type} | Mode: {self.mode}")

        refinement_passes = 0
        final_content = ""

        # Run primary pipeline
        for agent_role in self.pipeline:
            try:
                response = await self._run_agent(agent_role, user_prompt, task_type)

                if agent_role == AgentRole.SYNTHESIZER:
                    final_content = response.content

                if agent_role == AgentRole.JUDGE and self.mode == "deep":
                    score, approved, feedback = self._parse_judge_score(response.content)

                    # Refinement loop for deep mode
                    while not approved and refinement_passes < MAX_REFINEMENT_PASSES:
                        refinement_passes += 1
                        logger.info(f"Refinement pass {refinement_passes} (score: {score})")

                        # Add feedback to context
                        self.context["judge_feedback"] = feedback

                        # Re-run critic and synthesizer
                        await self._run_agent(AgentRole.CRITIC, user_prompt, task_type)
                        synth_response = await self._run_agent(
                            AgentRole.SYNTHESIZER, user_prompt, task_type
                        )
                        final_content = synth_response.content

                        # Re-judge
                        judge_response = await self._run_agent(
                            AgentRole.JUDGE, user_prompt, task_type
                        )
                        score, approved, feedback = self._parse_judge_score(
                            judge_response.content
                        )

            except asyncio.TimeoutError:
                logger.warning(f"Agent {agent_role.value} timed out, continuing pipeline")
                continue
            except Exception as e:
                logger.error(f"Agent {agent_role.value} failed: {e}")
                continue

        # If no synthesizer ran (fast mode edge case), use last agent output
        if not final_content and self.context:
            final_content = list(self.context.values())[-1]

        total_time = int((time.monotonic() - start_time) * 1000)

        # Build reasoning summary (sanitized for users)
        reasoning_summary = {
            "mode": self.mode,
            "task_type": task_type,
            "agents_used": len(self.steps),
            "refinement_passes": refinement_passes,
            "steps": [
                {
                    "agent": step["agent_role"],
                    "summary": step["summary"],
                    "latency_ms": step["latency_ms"],
                }
                for step in self.steps
            ],
        }

        return {
            "content": final_content,
            "task_type": task_type,
            "reasoning_summary": reasoning_summary,
            "total_tokens": self.total_tokens,
            "total_cost_usd": self.total_cost,
            "total_latency_ms": total_time,
            "refinement_passes": refinement_passes,
            "quality_score": None,  # Set by judge if available
            "steps": self.steps,  # Internal only — for DB logging
        }

    async def execute_streaming(self, user_prompt: str) -> AsyncGenerator[dict, None]:
        """Execute pipeline with streaming final synthesis.
        
        Yields status events during agent processing, then streams
        the final synthesized answer token by token.
        """
        task_type = classify_task(user_prompt)

        # Run all agents except synthesizer in non-streaming mode
        pre_synth_agents = [a for a in self.pipeline if a != AgentRole.SYNTHESIZER and a != AgentRole.JUDGE]

        for agent_role in pre_synth_agents:
            config = AGENT_CONFIGS[agent_role]
            yield {
                "type": "agent_start",
                "agent": agent_role.value,
                "display_name": config.display_name_de,
            }

            try:
                await self._run_agent(agent_role, user_prompt, task_type)
                yield {
                    "type": "agent_complete",
                    "agent": agent_role.value,
                    "summary": self._generate_step_summary(agent_role, ""),
                }
            except Exception as e:
                logger.error(f"Agent {agent_role.value} failed: {e}")
                yield {"type": "agent_error", "agent": agent_role.value}
                continue

        # Stream the synthesizer output
        if AgentRole.SYNTHESIZER in self.pipeline:
            yield {"type": "agent_start", "agent": "synthesizer", "display_name": "Synthesizer"}

            config = AGENT_CONFIGS[AgentRole.SYNTHESIZER]
            model = self._get_model_for_mode(AgentRole.SYNTHESIZER)
            system_prompt = AGENT_SYSTEM_PROMPTS[AgentRole.SYNTHESIZER]
            user_message = self._build_agent_input(AgentRole.SYNTHESIZER, user_prompt, task_type)

            full_content = ""
            async for token in llm_provider.stream(
                model=model,
                system_prompt=system_prompt,
                user_message=user_message,
                temperature=config.temperature,
                max_tokens=config.max_tokens,
            ):
                full_content += token
                yield {"type": "token", "content": token}

            self.context[AgentRole.SYNTHESIZER.value] = full_content
            yield {"type": "agent_complete", "agent": "synthesizer"}

        # Build final reasoning summary
        reasoning_summary = {
            "mode": self.mode,
            "task_type": task_type,
            "agents_used": len(self.steps),
            "steps": [
                {
                    "agent": step["agent_role"],
                    "summary": step["summary"],
                    "latency_ms": step["latency_ms"],
                }
                for step in self.steps
            ],
        }

        yield {
            "type": "complete",
            "reasoning_summary": reasoning_summary,
            "total_tokens": self.total_tokens,
            "total_cost_usd": self.total_cost,
        }
