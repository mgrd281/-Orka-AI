# ORKA AI — Product Strategy & Architecture

---

## 1. PRODUCT STRATEGY SUMMARY

**Orka AI** is a next-generation multi-agent intelligence platform that delivers premium AI answers by orchestrating multiple specialized AI agents behind every user prompt.

**Core Thesis:** Single-model AI produces flat, one-dimensional answers. Orka AI deploys a coordinated council of specialized agents — Analyst, Researcher, Creative, Critic, Synthesizer, and Quality Judge — that debate, refine, and synthesize elite-grade responses.

**Positioning:** "Koordinierte Intelligenz. Nicht ein KI-Modell — ein ganzes Team."
(Coordinated Intelligence. Not one AI model — an entire team.)

**Target Users:**
- Knowledge workers who need high-quality, reliable AI output
- Professionals (consultants, marketers, developers, writers)
- Power users frustrated with shallow AI answers
- Businesses requiring premium AI assistance

**Business Model:** Freemium SaaS with tiered subscriptions (Free / Pro / Premium)

**Key Metric North Stars:**
- Weekly Active Users (WAU)
- Messages per session
- Upgrade conversion rate
- 30-day retention

---

## 2. DIFFERENTIATION STRATEGY

| Dimension | Standard AI Chat | Orka AI |
|-----------|-----------------|---------|
| Architecture | Single model, single pass | Multi-agent orchestration |
| Answer Quality | Raw model output | Refined, critiqued, synthesized |
| Transparency | Black box | "So haben die KIs gedacht" |
| Modes | One speed | Fast / Smart / Deep |
| Feeling | Utility tool | Premium intelligence council |
| Identity | Generic chatbot | Distinctive, branded experience |

**Visible Differentiators:**
1. Agent collaboration animation during processing
2. "Denkprozess anzeigen" (Show thinking process) toggle
3. Quality score badges on answers
4. Mode selection with clear value explanation
5. Refined output formatting that feels editorially polished

---

## 3. FULL FEATURE MAP

### Core Features (MVP)
- [x] Multi-agent orchestration (6 agents)
- [x] Three intelligence modes (Schnell / Smart / Tief)
- [x] Chat system with conversations
- [x] Streaming responses
- [x] Auth (Email, Google, Apple)
- [x] Dark/Light mode
- [x] German primary, English, Arabic (RTL)
- [x] Subscription tiers
- [x] User settings & profile
- [x] Rich message formatting (Markdown)

### Enhanced Features (Phase 2)
- [ ] File upload (PDF, DOCX, TXT, images)
- [ ] Prompt templates & suggestions
- [ ] Prompt refinement assistant
- [ ] Voice input
- [ ] Image understanding
- [ ] Conversation search
- [ ] Export/share answers
- [ ] Admin dashboard

### Future Features (Phase 3)
- [ ] Custom agent configurations
- [ ] Team/workspace collaboration
- [ ] API access for developers
- [ ] Domain-specific agent packs
- [ ] Audio/video processing
- [ ] Plugin system

---

## 4. INFORMATION ARCHITECTURE

```
Orka AI
├── Onboarding
│   ├── Welcome Screen
│   ├── Value Proposition (3 slides)
│   ├── Language Selection
│   ├── Auth (Login / Register)
│   └── Mode Introduction
├── Main App
│   ├── Chat (Primary)
│   │   ├── New Conversation
│   │   ├── Conversation Thread
│   │   ├── Mode Selector
│   │   ├── Agent Thinking Indicator
│   │   └── Message Actions
│   ├── History (Sidebar / Tab)
│   │   ├── Conversation List
│   │   ├── Search
│   │   └── Archive/Delete
│   ├── Discover
│   │   ├── Prompt Templates
│   │   ├── Use Cases
│   │   └── Tips
│   └── Profile & Settings
│       ├── Account
│       ├── Subscription
│       ├── Preferences
│       ├── Language
│       ├── Appearance
│       └── Privacy
├── Subscription
│   ├── Plan Comparison
│   ├── Checkout
│   └── Management
└── Admin (Web Only)
    ├── Dashboard
    ├── Users
    ├── Analytics
    ├── Subscriptions
    ├── Agent Config
    └── System Health
```

---

## 5. USER FLOWS

### Flow 1: First Run
1. App opens → Language selection (default: Deutsch)
2. 3-slide onboarding → Value prop animation
3. Sign up / Sign in
4. Mode introduction overlay
5. First chat screen with suggested prompts

### Flow 2: Core Chat
1. User types prompt
2. Selects mode (or uses default: Smart)
3. Taps send
4. Agent orchestration begins → animated indicator
5. Streaming response appears
6. Optional: "Denkprozess anzeigen" expands reasoning
7. User can copy, share, or continue

### Flow 3: Upgrade
1. User hits free tier limit
2. Elegant paywall with clear value comparison
3. One-tap upgrade via Stripe
4. Immediate premium access

---

## 6. UX SCREEN MAP

1. **Splash Screen** — Logo animation, premium feel
2. **Onboarding Carousel** — 3 slides, language picker
3. **Auth Screen** — Login/Register, social auth
4. **Home / New Chat** — Empty state with suggestions
5. **Chat Thread** — Messages, agent indicator, mode selector
6. **Agent Thinking View** — Expandable reasoning summary
7. **History / Conversations** — List with search
8. **Settings** — Grouped sections
9. **Subscription** — Plan comparison cards
10. **Profile** — User info, usage stats
11. **Admin Dashboard** — Analytics, management (web)

---

## 7. DESIGN SYSTEM

### Brand Colors
```
Primary:        #6C5CE7 (Electric Violet — intelligence, premium)
Primary Dark:   #5A4BD1
Secondary:      #00D2FF (Cyan accent — futuristic, tech)
Surface Dark:   #0D0D1A (Deep navy-black)
Surface Card:   #161628 (Elevated card)
Surface Light:  #F8F9FC (Clean white)
Text Primary:   #FFFFFF (dark mode) / #1A1A2E (light mode)
Text Secondary: #8B8BA7
Success:        #00C48C
Warning:        #FFB800
Error:          #FF4757
```

### Typography
- **Display:** Inter (Bold, 28-32px)
- **Headings:** Inter (Semibold, 20-24px)
- **Body:** Inter (Regular, 15-16px)
- **Caption:** Inter (Medium, 12-13px)
- **Monospace:** JetBrains Mono (code blocks)

### Design Tokens
- Border Radius: 16px (cards), 12px (buttons), 24px (chips)
- Spacing Scale: 4, 8, 12, 16, 20, 24, 32, 48, 64
- Shadow (dark): 0 8px 32px rgba(0,0,0,0.4)
- Shadow (light): 0 4px 24px rgba(0,0,0,0.08)
- Glass effect: background blur 20px, opacity 0.1 white overlay

### Motion
- Page transitions: 300ms ease-out
- Micro-interactions: 200ms ease
- Agent thinking: pulsing orbital animation
- Message appear: fade-up 250ms staggered

---

## 8. PRODUCT NAME

**Selected: Orka AI**

Rationale:
- "Orka" evokes orchestration (Orchestrierung)
- Orcas are intelligent, coordinated pack hunters — perfect metaphor
- Short, memorable, globally pronounceable
- Works in German, English, and Arabic
- Strong .ai domain potential
- Premium sound without being generic

**Tagline (DE):** "Koordinierte Intelligenz"
**Tagline (EN):** "Coordinated Intelligence"
**Tagline (AR):** "ذكاء منسّق"

---

## 9. TECHNICAL ARCHITECTURE

```
┌─────────────────────────────────────────────────────┐
│                    CLIENT LAYER                       │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐              │
│  │   iOS   │  │ Android │  │   Web   │  (Flutter)    │
│  └────┬────┘  └────┬────┘  └────┬────┘              │
│       └─────────┬──┴───────────┘                     │
│            ┌────┴────┐                               │
│            │ API SDK │ (REST + WebSocket)             │
│            └────┬────┘                               │
└─────────────────┼───────────────────────────────────┘
                  │
┌─────────────────┼───────────────────────────────────┐
│            API GATEWAY (FastAPI)                      │
│  ┌──────────────┴──────────────┐                     │
│  │     Authentication Layer    │ (Supabase Auth)     │
│  │     Rate Limiting           │                     │
│  │     Request Validation      │                     │
│  └──────────────┬──────────────┘                     │
│  ┌──────────────┴──────────────┐                     │
│  │        ROUTER LAYER         │                     │
│  │  /chat  /auth  /user  /sub  │                     │
│  └──────────────┬──────────────┘                     │
└─────────────────┼───────────────────────────────────┘
                  │
┌─────────────────┼───────────────────────────────────┐
│          ORCHESTRATION ENGINE                         │
│  ┌──────────────┴──────────────┐                     │
│  │      Task Classifier        │                     │
│  │      Prompt Router          │                     │
│  └──────────────┬──────────────┘                     │
│  ┌──────────────┴──────────────┐                     │
│  │      Agent Manager          │                     │
│  │  ┌────────┐ ┌────────┐     │                     │
│  │  │Analyst │ │Research│     │                     │
│  │  ├────────┤ ├────────┤     │                     │
│  │  │Creative│ │ Critic │     │                     │
│  │  ├────────┤ ├────────┤     │                     │
│  │  │Synth.  │ │ Judge  │     │                     │
│  │  └────────┘ └────────┘     │                     │
│  └──────────────┬──────────────┘                     │
│  ┌──────────────┴──────────────┐                     │
│  │    Synthesis & Scoring      │                     │
│  │    Token Accounting         │                     │
│  │    Cost Tracking            │                     │
│  └─────────────────────────────┘                     │
└─────────────────────────────────────────────────────┘
                  │
┌─────────────────┼───────────────────────────────────┐
│            DATA LAYER                                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐            │
│  │PostgreSQL│ │  Redis   │ │ S3/Supa  │            │
│  │(Supabase)│ │ (Cache)  │ │ Storage  │            │
│  └──────────┘ └──────────┘ └──────────┘            │
└─────────────────────────────────────────────────────┘
                  │
┌─────────────────┼───────────────────────────────────┐
│          EXTERNAL SERVICES                           │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐            │
│  │ OpenAI   │ │Anthropic │ │  Stripe  │            │
│  │   API    │ │   API    │ │ Payments │            │
│  └──────────┘ └──────────┘ └──────────┘            │
│  ┌──────────┐ ┌──────────┐                          │
│  │ PostHog  │ │  Sentry  │                          │
│  │Analytics │ │  Errors  │                          │
│  └──────────┘ └──────────┘                          │
└─────────────────────────────────────────────────────┘
```

---

## 10. DATABASE SCHEMA

See `backend/app/models/` for full SQLAlchemy models.

**Core Tables:**
- `users` — profile, preferences, language
- `conversations` — chat threads with auto-title
- `messages` — user/assistant messages with metadata
- `agent_runs` — orchestration logs per message
- `agent_steps` — individual agent contributions
- `subscriptions` — plan, status, Stripe references
- `plans` — subscription plan definitions
- `usage_tracking` — token/message counts per user
- `file_uploads` — uploaded file references
- `admin_audit_log` — admin action tracking

---

## 11. API DESIGN

### Auth
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/social/{provider}`
- `DELETE /api/v1/auth/logout`

### Chat
- `POST /api/v1/chat/conversations` — create
- `GET /api/v1/chat/conversations` — list
- `GET /api/v1/chat/conversations/{id}` — get with messages
- `PATCH /api/v1/chat/conversations/{id}` — rename
- `DELETE /api/v1/chat/conversations/{id}` — delete
- `POST /api/v1/chat/conversations/{id}/messages` — send (SSE stream)
- `GET /api/v1/chat/conversations/{id}/reasoning` — get agent reasoning

### User
- `GET /api/v1/user/profile`
- `PATCH /api/v1/user/profile`
- `GET /api/v1/user/usage`
- `PATCH /api/v1/user/preferences`

### Subscriptions
- `GET /api/v1/subscriptions/plans`
- `POST /api/v1/subscriptions/checkout`
- `POST /api/v1/subscriptions/webhook` (Stripe)
- `GET /api/v1/subscriptions/current`
- `POST /api/v1/subscriptions/cancel`

### Admin
- `GET /api/v1/admin/dashboard`
- `GET /api/v1/admin/users`
- `GET /api/v1/admin/analytics`
- `GET /api/v1/admin/agents/config`
- `PATCH /api/v1/admin/agents/config`
- `GET /api/v1/admin/system/health`

---

## 12. AGENT ORCHESTRATION DESIGN

### Pipeline Per Mode

**Schnell (Fast):**
```
User Prompt → Analyst → Synthesizer → Response
Latency: ~2-4s | Agents: 2 | Cost: Low
```

**Smart (Default):**
```
User Prompt → Analyst → Researcher → Creative → Critic → Synthesizer → Response
Latency: ~6-12s | Agents: 5 | Cost: Medium
```

**Tief (Deep):**
```
User Prompt → Analyst → Researcher → Creative → Critic → Synthesizer → Judge
→ (if score < threshold) → Refine → Critic → Synthesizer → Judge → Response
Latency: ~15-30s | Agents: 6+ | Cost: High
```

### Task Classification
| Task Type | Agent Sequence | Output Style |
|-----------|---------------|-------------|
| Creative Writing | Analyst → Creative → Critic → Synthesizer | Expressive, polished |
| Business Analysis | Analyst → Researcher → Critic → Synthesizer | Structured, data-driven |
| Coding | Analyst → Researcher → Critic → Synthesizer | Technical, precise |
| Summarization | Analyst → Researcher → Synthesizer | Concise, clear |
| Research | Analyst → Researcher → Creative → Critic → Synthesizer | Comprehensive |
| Planning | Analyst → Creative → Researcher → Critic → Synthesizer | Actionable |

---

## 13. SUBSCRIPTION LOGIC

### Plans

| Feature | Kostenlos (Free) | Pro (€9.99/mo) | Premium (€24.99/mo) |
|---------|-----------------|-----------------|---------------------|
| Messages/day | 15 | 100 | Unlimited |
| Schnell Mode | ✓ | ✓ | ✓ |
| Smart Mode | 5/day | ✓ | ✓ |
| Tief Mode | ✗ | 10/day | ✓ |
| File Upload | ✗ | ✓ | ✓ |
| Conversation Memory | 7 days | 90 days | Unlimited |
| Priority Speed | ✗ | ✗ | ✓ |
| Agent Reasoning View | Limited | ✓ | ✓ |
| Export | ✗ | ✓ | ✓ |

---

## 14. ADMIN DASHBOARD

**Sections:**
1. **Overview** — KPIs: DAU, WAU, MAU, revenue, messages today
2. **Users** — List, search, view profiles, manage
3. **Analytics** — Charts: retention, messages, mode usage, conversion
4. **Revenue** — MRR, ARR, churn, LTV, plan distribution
5. **AI Operations** — Token usage, cost per model, agent performance, latency
6. **System** — Health checks, error rates, API performance
7. **Configuration** — Agent configs, feature flags, plan management

---

## 15. FOLDER STRUCTURE

See actual implementation below.

---

## 16. MVP SCOPE

**MVP (4-6 weeks):**
- Auth (email + social)
- Chat with multi-agent orchestration (3 modes)
- Streaming responses
- Conversation management
- Agent reasoning view
- Dark/Light mode
- German/English/Arabic
- Free tier + Pro subscription
- Basic settings
- iOS + Android + Web deployment

---

## 17. PHASE 2 ROADMAP

- File upload & processing
- Prompt templates & suggestions
- Admin dashboard
- Premium subscription tier
- Voice input
- Image understanding
- Conversation search & export
- Push notifications
- Usage analytics for users
- Advanced agent configurations

---

## 18. LAUNCH ROADMAP

| Week | Milestone |
|------|-----------|
| 1-2 | Backend + orchestration engine complete |
| 2-3 | Flutter app core UI + chat |
| 3-4 | Auth + subscriptions + settings |
| 4-5 | Polish, localization, testing |
| 5-6 | Beta TestFlight + Play Store internal |
| 6-7 | Landing page + public beta |
| 7-8 | App Store + Play Store + Web launch |
