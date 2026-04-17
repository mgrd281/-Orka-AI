# SYSTEM ARCHITECTURE — Orka AI

> High-level technical map of the product. Reference this when making structural decisions.

---

## Overview

Orka AI is a three-tier system: Flutter client → FastAPI backend → AI providers + data stores. The backend acts as an orchestration hub — it classifies tasks, routes prompts through agent pipelines, streams results, and tracks cost.

```
Flutter App (iOS / Android / Web)
        │
        ▼
FastAPI Backend (REST + SSE)
        │
   ┌────┼────┐
   ▼    ▼    ▼
 PostgreSQL  Redis  AI Providers
 (Supabase)         (OpenAI, Anthropic)
```

---

## Frontend Architecture

### Stack
- **Flutter** — single codebase for iOS, Android, Web
- **Riverpod** — state management (providers, notifiers)
- **go_router** — declarative routing with shell routes
- **Dio** — HTTP client with interceptors for auth token management
- **flutter_animate** — premium micro-interactions
- **flutter_markdown** — rich message rendering

### Structure

```
frontend/lib/
├── main.dart                      # App entry, ProviderScope, MaterialApp.router
├── core/
│   ├── theme/
│   │   ├── colors.dart            # OrkaColors — brand palette, dark/light, agent colors
│   │   ├── typography.dart        # OrkaTypography — Inter-based type scale
│   │   └── app_theme.dart         # Full ThemeData for dark and light modes
│   ├── router/
│   │   └── app_router.dart        # GoRouter config: onboarding → auth → main shell
│   ├── localization/
│   │   ├── app_localizations.dart # Delegate + translate() with fallback
│   │   ├── locale_notifier.dart   # Riverpod locale state
│   │   └── translations/         # DE (primary), EN, AR translation maps
│   ├── services/
│   │   └── api_service.dart       # Dio-based API client, auth token handling
│   └── constants/                 # App-wide constants
├── features/
│   ├── onboarding/screens/        # 3-slide intro, language picker
│   ├── auth/screens/              # Login / register with social auth
│   ├── chat/
│   │   ├── screens/
│   │   │   ├── chat_screen.dart          # Empty state, suggested prompts
│   │   │   └── conversation_screen.dart  # Active thread, streaming, reasoning
│   │   └── widgets/
│   │       ├── mode_selector.dart        # Schnell / Smart / Tief chips
│   │       ├── message_bubble.dart       # Markdown, copy, reasoning toggle
│   │       └── agent_thinking_indicator.dart  # Pulsing animation during orchestration
│   ├── settings/screens/          # Grouped settings (language, theme, privacy)
│   └── subscription/screens/      # Plan comparison cards, upgrade flow
└── shared/
    ├── widgets/                   # Reusable components (app_shell, etc.)
    ├── models/                    # Shared data models
    └── utils/                     # Helpers
```

### Key Patterns
- **Feature-based organization** — each domain owns its screens, widgets, providers
- **Theme-driven UI** — all colors, typography, and component styles come from `core/theme/`
- **Centralized API** — single `ApiService` instance via Riverpod provider
- **Locale-aware** — `AppLocalizations.of(context)` for all user-facing strings
- **Dark mode hero** — dark theme is primary; light theme supported but secondary

---

## Backend Architecture

### Stack
- **FastAPI** — async Python web framework
- **SQLAlchemy** (async) — ORM with asyncpg driver
- **Pydantic** — request/response validation, settings management
- **python-jose** + **passlib** — JWT auth with bcrypt password hashing
- **Stripe** — subscription checkout + webhook handling
- **Sentry** — error monitoring
- **Redis** — rate limiting, caching (future: session store)

### Structure

```
backend/app/
├── main.py                        # FastAPI app, CORS, middleware, health check
├── core/
│   ├── config.py                  # Pydantic Settings — all env vars
│   ├── database.py                # Async engine + session factory
│   └── security.py                # JWT create/verify, password hashing, auth deps
├── api/v1/
│   ├── auth/routes.py             # Register, login, refresh, social, logout
│   ├── chat/routes.py             # Conversations CRUD, message streaming (SSE)
│   ├── user/routes.py             # Profile, usage tracking
│   ├── subscriptions/routes.py    # Plans, checkout, webhook, cancel
│   └── admin/routes.py            # Dashboard stats, user management
├── models/                        # SQLAlchemy models (User, Conversation, Message, etc.)
├── schemas/
│   └── api.py                     # Pydantic request/response schemas
├── services/
│   ├── agents/
│   │   ├── definitions.py         # AgentRole enum, configs, system prompts, mode pipelines
│   │   └── llm_provider.py        # Unified OpenAI/Anthropic client with retry + cost tracking
│   └── orchestration/
│       ├── pipeline.py            # OrchestrationPipeline — execute() and execute_streaming()
│       └── task_classifier.py     # Keyword-based task classification → agent routing
├── middleware/
│   └── rate_limit.py              # In-memory rate limiter
└── utils/                         # Helpers
```

### Key Patterns
- **Clean separation**: routes handle HTTP, services handle logic, models handle data
- **Dependency injection**: `get_db`, `get_current_user`, `get_admin_user` via FastAPI Depends
- **Streaming via SSE**: `/conversations/{id}/messages` returns Server-Sent Events
- **Versioned API**: all routes under `/api/v1/`
- **German-first error messages**: user-facing errors returned in German

---

## AI Orchestration Architecture

### Components

```
User Prompt
    │
    ▼
Task Classifier ──→ determines task_type (creative, analysis, coding, etc.)
    │
    ▼
Mode Pipeline ──→ selects agent sequence based on mode + task_type
    │
    ▼
Agent Manager ──→ runs agents sequentially, accumulates context
    │
    ├── Agent: Analyst       (understand, decompose)
    ├── Agent: Researcher    (find information, verify)
    ├── Agent: Creative      (generate ideas, alternatives)
    ├── Agent: Critic        (find flaws, challenge assumptions)
    ├── Agent: Synthesizer   (combine into final answer)
    └── Agent: Judge         (score quality, trigger refinement — Deep mode only)
    │
    ▼
Streaming Response ──→ SSE tokens to client
    │
    ▼
Cost Tracking ──→ log tokens, model, cost per agent per request
```

### Design Principles

1. **Agents are configs, not classes.** Each agent is defined by role, model, temperature, max_tokens, and system prompt. No class inheritance.
2. **Pipeline is data-driven.** Mode + task type → agent sequence lookup. Adding a new mode or task type means editing config, not code.
3. **Context accumulation.** Each agent receives the accumulated context from prior agents, not just the raw prompt.
4. **Provider abstraction.** `LLMProvider` wraps OpenAI and Anthropic with a unified `complete()` / `stream()` interface. Switching a model is a config change.
5. **Cost awareness.** Every LLM call logs input/output tokens and computes cost from `MODEL_COSTS` dict. Pipeline returns total cost.
6. **Refinement loops.** Deep mode only: if Judge scores below threshold, the pipeline re-runs Critic → Synthesizer → Judge (max 2 iterations).

### Cost Control Rules

- Fast mode by default for simple/short prompts
- Smart mode for standard queries
- Deep mode only when user explicitly selects it
- Task classifier can recommend downgrading mode for trivial tasks
- Token limits enforced per agent (configurable in `AGENT_CONFIGS`)
- Total request cost tracked in `usage_tracking` table

---

## Localization Architecture

```
core/localization/
├── app_localizations.dart    # AppLocalizations class with translate() + delegate
├── locale_notifier.dart      # Riverpod StateNotifier for locale management
└── translations/
    ├── de.dart               # German (primary, authoritative)
    ├── en.dart               # English
    └── ar.dart               # Arabic
```

- Translation maps are `Map<String, String>` keyed by translation key.
- `AppLocalizations.of(context)` returns the current locale's translator.
- Fallback chain: requested locale → German → key itself.
- German translations are the source of truth. EN and AR are translations of DE, not the other way around.
- Arabic triggers `TextDirection.rtl` — layout, padding, icons must adapt.

---

## Auth & Security

- JWT access tokens (short-lived) + refresh tokens (long-lived)
- Passwords hashed with bcrypt via passlib
- `get_current_user` dependency extracts and validates JWT on protected routes
- `get_admin_user` adds role check
- Stripe webhooks verified via signature
- Rate limiting per IP (middleware)
- CORS configured for known origins
- Secrets via environment variables, never committed

---

## Payments

- Stripe Checkout Sessions for subscription upgrades
- Webhook handler for `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`
- Plan definitions stored in DB (`plans` table) with localized display names
- `subscriptions` table tracks active plan, Stripe customer/subscription IDs, status

---

## Data Layer

- **PostgreSQL** (via Supabase): primary data store for users, conversations, messages, subscriptions, usage tracking, agent runs
- **Redis**: rate limiting counters, future: response caching, session store
- **Supabase Storage / S3**: file uploads (Phase 2)
- **Alembic**: database migrations

---

## Observability

| Concern | Tool | Status |
|---------|------|--------|
| Error tracking | Sentry | Configured in `main.py` |
| Analytics | PostHog | Planned |
| Logging | Python `logging` / structured | Basic |
| Token cost tracking | Custom `usage_tracking` table | Implemented |
| API latency | Middleware timing (planned) | Planned |
| Agent performance | `agent_runs` + `agent_steps` tables | Implemented |

---

## Future Scalability Notes

- Backend is stateless — horizontal scaling via container replicas
- Database connection pooling via asyncpg
- Redis for distributed rate limiting when scaling beyond single instance
- Agent pipelines can be parallelized (Analyst + Researcher concurrently) in future optimization
- File processing (Phase 2) should use background workers (Celery / ARQ), not in-request
- WebSocket upgrade path for real-time features beyond SSE
- CDN for static Flutter Web assets
- Multi-region deployment feasible — Supabase supports region selection

---

## Module Boundaries

| Module | Owns | Does NOT Own |
|--------|------|-------------|
| `api/` | HTTP routing, request parsing, response formatting | Business logic, DB queries |
| `services/` | Business logic, orchestration, external API calls | HTTP concerns, response formatting |
| `models/` | DB schema, table definitions | Query logic, business rules |
| `schemas/` | Request/response validation shapes | DB models, business logic |
| `core/` | Config, security, database setup | Feature-specific logic |
| `middleware/` | Cross-cutting concerns (rate limit, CORS) | Route-specific logic |

Keep these boundaries clean. A route handler should call a service, which calls a model — never the reverse.
