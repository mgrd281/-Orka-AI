# Orka AI Backend

> Before working on the backend, read the project governance docs in the repo root:
> `PROJECT_BRIEF.md` → `AI_RULES.md` → `SYSTEM_ARCHITECTURE.md` → `TASK_EXECUTION_PROTOCOL.md`

## Setup

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # Configure your environment
uvicorn app.main:app --reload
```

## Architecture
- **FastAPI** application with modular router structure
- **SQLAlchemy** async ORM with PostgreSQL
- **Alembic** for database migrations
- **Multi-agent orchestration** engine
- **SSE streaming** for real-time responses
- **Stripe** integration for subscriptions
