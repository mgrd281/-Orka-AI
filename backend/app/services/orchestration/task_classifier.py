"""
Orka AI — Task Classifier

Classifies user prompts into task types to optimize agent pipeline behavior.
"""

from app.services.agents.definitions import TASK_TYPE_HINTS


def classify_task(prompt: str) -> str:
    """Classify the user prompt into a task type."""
    prompt_lower = prompt.lower()

    scores: dict[str, int] = {}
    for task_type, keywords in TASK_TYPE_HINTS.items():
        score = sum(1 for kw in keywords if kw in prompt_lower)
        if score > 0:
            scores[task_type] = score

    if not scores:
        return "general"

    return max(scores, key=scores.get)


# Output style recommendations per task type
TASK_OUTPUT_STYLES: dict[str, str] = {
    "creative_writing": "Write in an expressive, polished literary style. Use vivid language and strong structure.",
    "business_analysis": "Use a structured, data-driven format. Include clear sections, bullet points, and actionable insights.",
    "coding": "Provide clean, well-commented code with clear explanations. Use proper formatting and best practices.",
    "summarization": "Be concise and clear. Use bullet points for key takeaways. Prioritize signal over noise.",
    "research": "Be comprehensive but organized. Use sections, evidence, and clear argumentation.",
    "marketing": "Be persuasive, creative, and brand-aware. Use compelling copy and clear value propositions.",
    "planning": "Create actionable, structured plans. Use timelines, priorities, and clear next steps.",
    "problem_solving": "Identify root causes, explore solutions systematically, and recommend the best path forward.",
    "general": "Provide a clear, helpful, and well-structured response adapted to the user's apparent need.",
}
