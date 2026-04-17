# PROJECT BRIEF — Orka AI

> Authoritative project summary. Read this file first before scanning implementation code.

---

## Product

**Name:** Orka AI
**Type:** Premium multi-agent AI platform
**Tagline (DE):** "Koordinierte Intelligenz"
**Tagline (EN):** "Coordinated Intelligence"

## Core Idea

Users submit one prompt. Multiple specialized AI agents — Analyst, Researcher, Creative, Critic, Synthesizer, Quality Judge — collaborate internally to analyze, debate, refine, and synthesize the strongest possible answer.

Orka AI is not a chatbot wrapper. It is an orchestrated intelligence system that delivers meaningfully better answers than any single model pass.

## Platforms

- iOS (native via Flutter)
- Android (native via Flutter)
- Web (Flutter Web)

## Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart), Riverpod, go_router, Dio |
| Backend | FastAPI (Python), async SQLAlchemy, Pydantic |
| Database | PostgreSQL via Supabase |
| Cache | Redis |
| Auth | JWT (python-jose) + Supabase Auth |
| Payments | Stripe (checkout sessions + webhooks) |
| AI Providers | OpenAI API, Anthropic API |
| Observability | Sentry (errors), PostHog (analytics) |
| Storage | Supabase Storage / S3 |

## Languages

| Language | Role | Notes |
|----------|------|-------|
| **German (de)** | Primary default | All UI, prompts, errors default to German |
| English (en) | Fully supported | Complete translation coverage |
| Arabic (ar) | Fully supported | **Full RTL layout required** |

German must feel native and premium — not translated-from-English. Arabic must be first-class RTL, not an afterthought.

## Intelligence Modes

| Mode | German Name | Agents | Latency | Cost |
|------|------------|--------|---------|------|
| Fast | Schnell | 2 (Analyst → Synthesizer) | ~2-4s | Low |
| Smart | Smart (default) | 5 (full pipeline minus Judge) | ~6-12s | Medium |
| Deep | Tief | 6+ (full pipeline + refinement loops) | ~15-30s | High |

## Subscription Plans

| Plan | Price | Key Limits |
|------|-------|-----------|
| Kostenlos (Free) | €0 | 15 msg/day, Fast mode, limited Smart |
| Pro | €9.99/mo | 100 msg/day, Smart + limited Deep |
| Premium | €24.99/mo | Unlimited, all modes, priority speed |

## Key Features (MVP)

- Multi-agent orchestration with 3 modes
- Chat with streaming SSE responses
- "Denkprozess anzeigen" — transparent agent reasoning
- Conversation management (create, rename, delete, history)
- Auth (email + social)
- Subscription management via Stripe
- Dark/Light mode (dark hero)
- Full DE/EN/AR localization

## UX Direction

- Premium, elegant, minimal — not a generic chatbot skin
- Dark mode is the hero experience
- Electric Violet (#6C5CE7) primary, Cyan (#00D2FF) accent
- Inter typeface throughout
- Agent thinking animations during processing
- Every element must sell, build trust, or clarify

## Technical Priorities

1. **Modularity** — clean domain separation, replaceable components
2. **Cost efficiency** — route cheap tasks to Fast mode, expensive chains only when justified
3. **Token accounting** — track spend per user, per agent, per model
4. **Latency awareness** — stream early, show progress, minimize perceived wait
5. **Production readiness** — error handling, rate limiting, observability from day one
6. **Scalability** — stateless API, async everywhere, horizontal scaling path

## AI Orchestration Priorities

1. Task classification determines agent pipeline — not every prompt needs all agents
2. Default to efficient routing before expensive deep reasoning
3. Judge scoring with refinement loops only in Deep mode
4. Cost tracking per request, per agent, per model
5. Agent configs externalized — adjustable without code changes
6. Provider abstraction — swap OpenAI/Anthropic per agent without rewiring

## Related Documents

- [PRODUCT_STRATEGY.md](PRODUCT_STRATEGY.md) — full strategy, features, DB schema, API design
- [AI_RULES.md](AI_RULES.md) — operating rules for AI-assisted development
- [SYSTEM_ARCHITECTURE.md](SYSTEM_ARCHITECTURE.md) — technical architecture map
- [TASK_EXECUTION_PROTOCOL.md](TASK_EXECUTION_PROTOCOL.md) — task workflow for AI agents
