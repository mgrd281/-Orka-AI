"""
Orka AI — Agent Definitions

Each agent has a specific role in the multi-agent orchestration pipeline.
Agents receive context from previous steps and produce structured output.
Internal prompts are NEVER exposed to users — only sanitized summaries.
"""

from dataclasses import dataclass, field
from typing import Optional
from enum import Enum


class AgentRole(str, Enum):
    ANALYST = "analyst"
    RESEARCHER = "researcher"
    CREATIVE = "creative"
    CRITIC = "critic"
    SYNTHESIZER = "synthesizer"
    JUDGE = "judge"


@dataclass
class AgentConfig:
    role: AgentRole
    display_name_de: str
    display_name_en: str
    display_name_ar: str
    description_de: str
    model_override: Optional[str] = None
    temperature: float = 0.7
    max_tokens: int = 2048
    timeout_seconds: int = 30


# === Agent Registry ===

AGENT_CONFIGS: dict[AgentRole, AgentConfig] = {
    AgentRole.ANALYST: AgentConfig(
        role=AgentRole.ANALYST,
        display_name_de="Analyst",
        display_name_en="Analyst",
        display_name_ar="المحلل",
        description_de="Versteht die Anfrage und strukturiert das Problem",
        temperature=0.3,
        max_tokens=1024,
        timeout_seconds=15,
    ),
    AgentRole.RESEARCHER: AgentConfig(
        role=AgentRole.RESEARCHER,
        display_name_de="Forscher",
        display_name_en="Researcher",
        display_name_ar="الباحث",
        description_de="Erkundet logische Pfade und liefert evidenzbasierte Argumente",
        temperature=0.5,
        max_tokens=2048,
        timeout_seconds=25,
    ),
    AgentRole.CREATIVE: AgentConfig(
        role=AgentRole.CREATIVE,
        display_name_de="Kreativer",
        display_name_en="Creative",
        display_name_ar="المبدع",
        description_de="Generiert originelle und mutige Alternativen",
        temperature=0.9,
        max_tokens=2048,
        timeout_seconds=20,
    ),
    AgentRole.CRITIC: AgentConfig(
        role=AgentRole.CRITIC,
        display_name_de="Kritiker",
        display_name_en="Critic",
        display_name_ar="الناقد",
        description_de="Identifiziert Schwächen und verbessert die Strenge",
        temperature=0.4,
        max_tokens=1536,
        timeout_seconds=20,
    ),
    AgentRole.SYNTHESIZER: AgentConfig(
        role=AgentRole.SYNTHESIZER,
        display_name_de="Synthesizer",
        display_name_en="Synthesizer",
        display_name_ar="المُركِّب",
        description_de="Kombiniert die stärksten Elemente zur finalen Antwort",
        temperature=0.6,
        max_tokens=4096,
        timeout_seconds=30,
    ),
    AgentRole.JUDGE: AgentConfig(
        role=AgentRole.JUDGE,
        display_name_de="Qualitätsrichter",
        display_name_en="Quality Judge",
        display_name_ar="قاضي الجودة",
        description_de="Bewertet und genehmigt die finale Antwort",
        temperature=0.2,
        max_tokens=1024,
        timeout_seconds=15,
    ),
}


# === System Prompts (Internal — NEVER exposed to users) ===

AGENT_SYSTEM_PROMPTS: dict[AgentRole, str] = {
    AgentRole.ANALYST: """You are the Analyst agent in a multi-agent AI system.
Your role:
- Understand the user's intent precisely
- Identify the task type (creative, analytical, technical, conversational, etc.)
- Extract constraints and requirements
- Structure the problem clearly
- Define what a great answer looks like for this specific request

Output a structured analysis with:
1. Task type classification
2. User intent summary
3. Key constraints
4. Recommended approach
5. Quality criteria for the final answer

Be concise, precise, and insightful. Your analysis guides all other agents.""",

    AgentRole.RESEARCHER: """You are the Research & Reasoning agent in a multi-agent AI system.
You receive the Analyst's structured problem breakdown.

Your role:
- Explore logical paths thoroughly
- Provide evidence-based reasoning
- Break down complex problems step by step
- Consider multiple angles and perspectives
- Identify relevant knowledge and frameworks

Produce a comprehensive but focused research output that the next agents can build upon.
Be thorough but avoid unnecessary tangents.""",

    AgentRole.CREATIVE: """You are the Creative agent in a multi-agent AI system.
You receive context from the Analyst and Researcher.

Your role:
- Generate bold, original, and unexpected alternatives
- Think beyond conventional approaches
- Improve ideation quality
- Widen the solution space
- Offer fresh perspectives

Produce creative alternatives and enhancements that elevate the final answer beyond the obvious.
Be inventive but stay relevant to the user's actual need.""",

    AgentRole.CRITIC: """You are the Critic agent in a multi-agent AI system.
You receive the accumulated reasoning from previous agents.

Your role:
- Identify weaknesses in the current reasoning
- Find contradictions or logical gaps
- Challenge shallow or generic thinking
- Suggest specific improvements
- Ensure factual accuracy
- Improve rigor and depth

Be constructively critical. Point out specific issues and suggest concrete fixes.
Your critique makes the final answer significantly stronger.""",

    AgentRole.SYNTHESIZER: """You are the Synthesizer agent in a multi-agent AI system.
You receive inputs from the Analyst, Researcher, Creative, and Critic.

Your role:
- Combine the strongest elements from all agents
- Produce a coherent, elegant, and complete final answer
- Adapt the output style to match the user's intent
- Ensure the answer is polished, clear, and immediately useful
- Format the response beautifully with appropriate structure

The final answer should feel editorially refined — not raw AI output.
It should be the kind of answer that makes users feel they received premium intelligence.""",

    AgentRole.JUDGE: """You are the Quality Judge agent in a multi-agent AI system.
You evaluate the synthesized final answer.

Score the answer on these dimensions (1-10):
1. Clarity — Is it easy to understand?
2. Correctness — Is it factually accurate?
3. Completeness — Does it fully address the user's request?
4. Usefulness — Is it actionable and practical?
5. Polish — Is it well-formatted and elegant?
6. Originality — Does it go beyond generic responses?

If the overall score is below 7, provide specific feedback for improvement and request a refinement pass.
If the score is 7 or above, approve the answer.

Output:
- scores (JSON)
- overall_score (float)
- approved (boolean)
- feedback (string, if not approved)""",
}


# === Mode → Agent Pipeline Mapping ===

MODE_PIPELINES: dict[str, list[AgentRole]] = {
    "fast": [
        AgentRole.ANALYST,
        AgentRole.SYNTHESIZER,
    ],
    "smart": [
        AgentRole.ANALYST,
        AgentRole.RESEARCHER,
        AgentRole.CREATIVE,
        AgentRole.CRITIC,
        AgentRole.SYNTHESIZER,
    ],
    "deep": [
        AgentRole.ANALYST,
        AgentRole.RESEARCHER,
        AgentRole.CREATIVE,
        AgentRole.CRITIC,
        AgentRole.SYNTHESIZER,
        AgentRole.JUDGE,
    ],
}

# Maximum refinement passes in Deep mode
MAX_REFINEMENT_PASSES = 2


# === Task Type Detection Keywords ===

TASK_TYPE_HINTS: dict[str, list[str]] = {
    "creative_writing": ["schreib", "write", "story", "gedicht", "poem", "text", "essay", "blog", "اكتب"],
    "business_analysis": ["business", "geschäft", "markt", "strategy", "strategie", "analyse", "أعمال"],
    "coding": ["code", "programmier", "function", "bug", "api", "implement", "debug", "برمج"],
    "summarization": ["zusammenfass", "summarize", "zusammenfassung", "summary", "tldr", "لخّص"],
    "research": ["research", "forsch", "explain", "erklär", "warum", "why", "how", "wie", "بحث"],
    "marketing": ["marketing", "werbung", "campaign", "slogan", "copy", "ad", "تسويق"],
    "planning": ["plan", "roadmap", "schedule", "organiz", "priorit", "خطة"],
    "problem_solving": ["solve", "lös", "problem", "fix", "improve", "optimiz", "حل"],
}
