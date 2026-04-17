# TASK EXECUTION PROTOCOL — Orka AI

> Strict workflow for AI agents executing tasks in this repository.
> Follow this protocol for every task. No exceptions.

---

## Workflow

### Step 1 — Load Context

Read these files (in order) before inspecting any implementation code:

1. `PROJECT_BRIEF.md` — product summary, stack, priorities
2. `AI_RULES.md` — operating rules, quality standards, anti-patterns
3. `SYSTEM_ARCHITECTURE.md` — only if the task involves structural decisions

If you already read them in this session and context is retained, do not re-read.

### Step 2 — Scope the Task

Before opening any file:

- Identify which domain the task belongs to (auth, chat, orchestration, UI, localization, etc.)
- Identify which layer is affected (frontend, backend, or both)
- List the likely files involved (no more than what's needed)
- Determine whether this is a new feature, a bug fix, a refactor, or a configuration change

### Step 3 — Inspect Relevant Files Only

- Read only the files you identified in Step 2.
- If a file is large, read only the relevant section.
- Do not scan entire directories "for context" unless you genuinely need it.
- If a previous search already returned the needed information, do not search again.

**Stop condition:** You have enough context to make the change correctly. Proceed.

### Step 4 — Identify the Minimal Clean Path

Before writing code:

- What is the smallest change that correctly achieves the goal?
- Does a similar pattern already exist in the codebase? Use it.
- Does an existing utility, widget, or service already handle part of this? Reuse it.
- Will the change require updates in multiple files? List them.
- Will the change affect localization? Plan DE/EN/AR strings.

### Step 5 — Implement

- Make targeted edits. Do not rewrite untouched code.
- Match existing patterns: naming, structure, imports, error handling.
- Add localization strings for all new user-facing text (DE primary, EN, AR).
- Add RTL considerations if the change involves layout.
- Mark incomplete work with `// TODO:` — never leave silent gaps.
- If creating a new file, place it in the correct domain folder per architecture.

### Step 6 — Verify

- Check that imports are correct and files are referenced properly.
- Check that new code doesn't break existing patterns.
- If the change involves localization, verify all three language maps are updated.
- If the change involves API, verify request/response schemas match.

### Step 7 — Summarize

Provide a brief summary:

```
Changed: [list of files]
What: [one-sentence description]
Risks: [any risks or follow-up needed, or "None"]
```

Keep it short. No filler. No re-explaining what the user asked for.

---

## When to Expand Scope

Sometimes a task requires broader analysis. This is acceptable when:

- The task explicitly asks for architecture review or refactoring
- A bug cannot be traced without understanding data flow across modules
- The user asks "what's the current state of X"
- A new feature requires understanding how multiple modules connect

Even then, expand methodically — don't dump full directory listings.

---

## When NOT to Expand Scope

- Adding a new screen → inspect the feature folder + router, not the entire app
- Fixing a backend endpoint → inspect the route + service + schema, not all routes
- Adding a translation key → inspect the localization files, not the entire frontend
- Changing agent behavior → inspect the agent definitions + pipeline, not the full backend

---

## Output Rules

| Situation | Expected Output |
|-----------|----------------|
| Code task | Code changes + brief summary |
| Question about codebase | Direct answer with file references |
| Architecture decision | Recommendation with reasoning (concise) |
| Bug investigation | Root cause + fix, or narrowed-down candidates |
| Multiple options | Recommend the best one and explain why briefly |

Do not:
- Explain what you're about to do before doing it
- Recap the user's request back to them
- List alternatives unless asked
- Apologize or hedge
- Use filler phrases

---

## Localization Checkpoint

For any task that adds or changes user-facing text:

- [ ] German string added (primary, must feel native)
- [ ] English string added
- [ ] Arabic string added
- [ ] RTL layout verified (if layout change)
- [ ] String key follows existing naming convention
- [ ] No hardcoded strings in widgets or screens

---

## Cost Checkpoint

For any task that changes AI orchestration:

- [ ] Does this increase per-request cost? By how much?
- [ ] Is the cost justified for the user value delivered?
- [ ] Can a cheaper model or shorter pipeline achieve the same result?
- [ ] Is token usage tracked for the new/changed flow?
- [ ] Does this respect mode boundaries (Fast = cheap, Deep = expensive)?

---

## File Placement Guide

| What | Where |
|------|-------|
| New screen | `frontend/lib/features/{domain}/screens/` |
| New widget | `frontend/lib/features/{domain}/widgets/` or `shared/widgets/` |
| New provider | `frontend/lib/features/{domain}/providers/` |
| New API route | `backend/app/api/v1/{domain}/routes.py` |
| New service | `backend/app/services/{domain}/` |
| New model | `backend/app/models/` |
| New schema | `backend/app/schemas/` |
| New agent | `backend/app/services/agents/definitions.py` (config + prompt) |
| Translation strings | `frontend/lib/core/localization/app_localizations.dart` |
| Theme change | `frontend/lib/core/theme/` |
| Route change | `frontend/lib/core/router/app_router.dart` |
| Config change | `backend/app/core/config.py` |
