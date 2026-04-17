# Orka AI

**Koordinierte Intelligenz.** Premium multi-agent AI platform for iOS, Android, and Web.

## Project Governance

Before working on this codebase — read these files first, in order:

| File | Purpose |
|------|---------|
| [PROJECT_BRIEF.md](PROJECT_BRIEF.md) | Product summary, stack, priorities |
| [AI_RULES.md](AI_RULES.md) | Operating rules for AI-assisted development |
| [SYSTEM_ARCHITECTURE.md](SYSTEM_ARCHITECTURE.md) | Technical architecture map |
| [TASK_EXECUTION_PROTOCOL.md](TASK_EXECUTION_PROTOCOL.md) | Task workflow and execution discipline |
| [PRODUCT_STRATEGY.md](PRODUCT_STRATEGY.md) | Full strategy, features, DB schema, API design |

## Quick Start

### Backend
```bash
cd backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## Stack

- **Frontend:** Flutter (iOS, Android, Web)
- **Backend:** FastAPI, SQLAlchemy (async), PostgreSQL
- **AI:** OpenAI + Anthropic via unified provider
- **Payments:** Stripe
- **Infra:** Supabase, Redis, Sentry
