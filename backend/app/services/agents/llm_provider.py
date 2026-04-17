"""
Orka AI — AI Provider Abstraction Layer

Supports OpenAI and Anthropic with unified interface.
Handles retries, timeouts, token counting, and cost tracking.
"""

import time
import asyncio
from typing import AsyncGenerator, Optional
from dataclasses import dataclass

import openai
import anthropic
from tenacity import retry, stop_after_attempt, wait_exponential

from app.core.config import settings


@dataclass
class LLMResponse:
    content: str
    tokens_input: int
    tokens_output: int
    model: str
    latency_ms: int
    cost_usd: float


# Cost per 1M tokens (approximate, update as needed)
MODEL_COSTS = {
    "gpt-4o-mini": {"input": 0.15, "output": 0.60},
    "gpt-4o": {"input": 2.50, "output": 10.00},
    "gpt-4-turbo": {"input": 10.00, "output": 30.00},
    "claude-sonnet-4-20250514": {"input": 3.00, "output": 15.00},
    "claude-opus-4-20250514": {"input": 15.00, "output": 75.00},
    "claude-3-haiku-20240307": {"input": 0.25, "output": 1.25},
}


def calculate_cost(model: str, tokens_input: int, tokens_output: int) -> float:
    costs = MODEL_COSTS.get(model, {"input": 5.0, "output": 15.0})
    return (tokens_input * costs["input"] + tokens_output * costs["output"]) / 1_000_000


class LLMProvider:
    def __init__(self):
        self._openai_client = None
        self._anthropic_client = None

    @property
    def openai_client(self) -> openai.AsyncOpenAI:
        if not self._openai_client:
            self._openai_client = openai.AsyncOpenAI(api_key=settings.openai_api_key)
        return self._openai_client

    @property
    def anthropic_client(self) -> anthropic.AsyncAnthropic:
        if not self._anthropic_client:
            self._anthropic_client = anthropic.AsyncAnthropic(api_key=settings.anthropic_api_key)
        return self._anthropic_client

    def _is_anthropic(self, model: str) -> bool:
        return "claude" in model.lower()

    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=1, max=10))
    async def complete(
        self,
        model: str,
        system_prompt: str,
        user_message: str,
        temperature: float = 0.7,
        max_tokens: int = 2048,
        timeout_seconds: int = 30,
    ) -> LLMResponse:
        start = time.monotonic()

        if self._is_anthropic(model):
            response = await asyncio.wait_for(
                self.anthropic_client.messages.create(
                    model=model,
                    max_tokens=max_tokens,
                    temperature=temperature,
                    system=system_prompt,
                    messages=[{"role": "user", "content": user_message}],
                ),
                timeout=timeout_seconds,
            )
            content = response.content[0].text
            tokens_input = response.usage.input_tokens
            tokens_output = response.usage.output_tokens
        else:
            response = await asyncio.wait_for(
                self.openai_client.chat.completions.create(
                    model=model,
                    temperature=temperature,
                    max_tokens=max_tokens,
                    messages=[
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": user_message},
                    ],
                ),
                timeout=timeout_seconds,
            )
            content = response.choices[0].message.content
            tokens_input = response.usage.prompt_tokens
            tokens_output = response.usage.completion_tokens

        latency = int((time.monotonic() - start) * 1000)
        cost = calculate_cost(model, tokens_input, tokens_output)

        return LLMResponse(
            content=content,
            tokens_input=tokens_input,
            tokens_output=tokens_output,
            model=model,
            latency_ms=latency,
            cost_usd=cost,
        )

    async def stream(
        self,
        model: str,
        system_prompt: str,
        user_message: str,
        temperature: float = 0.7,
        max_tokens: int = 4096,
    ) -> AsyncGenerator[str, None]:
        """Stream response tokens for real-time output."""
        if self._is_anthropic(model):
            async with self.anthropic_client.messages.stream(
                model=model,
                max_tokens=max_tokens,
                temperature=temperature,
                system=system_prompt,
                messages=[{"role": "user", "content": user_message}],
            ) as stream:
                async for text in stream.text_stream:
                    yield text
        else:
            stream = await self.openai_client.chat.completions.create(
                model=model,
                temperature=temperature,
                max_tokens=max_tokens,
                stream=True,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_message},
                ],
            )
            async for chunk in stream:
                if chunk.choices[0].delta.content:
                    yield chunk.choices[0].delta.content


# Singleton
llm_provider = LLMProvider()
