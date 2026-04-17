from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime


# === Auth ===

class RegisterRequest(BaseModel):
    email: str
    password: str
    full_name: Optional[str] = None
    language: str = "de"


class LoginRequest(BaseModel):
    email: str
    password: str


class SocialAuthRequest(BaseModel):
    provider: str  # google, apple
    token: str
    full_name: Optional[str] = None


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class RefreshRequest(BaseModel):
    refresh_token: str


# === User ===

class UserProfile(BaseModel):
    id: str
    email: str
    full_name: Optional[str]
    avatar_url: Optional[str]
    language: str
    theme: str
    default_mode: str
    role: str
    created_at: datetime

    class Config:
        from_attributes = True


class UpdateProfileRequest(BaseModel):
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    language: Optional[str] = None
    theme: Optional[str] = None
    default_mode: Optional[str] = None


# === Conversation ===

class CreateConversationRequest(BaseModel):
    mode: str = "smart"


class ConversationResponse(BaseModel):
    id: str
    title: Optional[str]
    mode: str
    message_count: int
    is_archived: bool
    is_pinned: bool
    last_message_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


class UpdateConversationRequest(BaseModel):
    title: Optional[str] = None
    is_archived: Optional[bool] = None
    is_pinned: Optional[bool] = None


# === Message ===

class SendMessageRequest(BaseModel):
    content: str
    mode: str = "smart"  # fast, smart, deep


class MessageResponse(BaseModel):
    id: str
    role: str
    content: str
    mode: Optional[str]
    quality_score: Optional[float]
    reasoning_summary: Optional[dict]
    latency_ms: int
    created_at: datetime

    class Config:
        from_attributes = True


class ConversationDetailResponse(BaseModel):
    conversation: ConversationResponse
    messages: list[MessageResponse]


# === Agent Reasoning ===

class AgentStepSummary(BaseModel):
    agent_role: str
    summary: Optional[str]
    latency_ms: int
    sequence: int


class ReasoningSummaryResponse(BaseModel):
    mode: str
    task_type: Optional[str]
    total_latency_ms: int
    refinement_passes: int
    steps: list[AgentStepSummary]


# === Subscription ===

class PlanResponse(BaseModel):
    id: str
    name: str
    display_name: str  # Localized at API level
    description: str  # Localized at API level
    price_monthly_eur: float
    messages_per_day: int
    smart_messages_per_day: int
    deep_messages_per_day: int
    file_upload_enabled: bool
    conversation_retention_days: int
    priority_speed: bool
    reasoning_view_full: bool
    export_enabled: bool


class SubscriptionResponse(BaseModel):
    plan: PlanResponse
    status: str
    current_period_end: Optional[datetime]

    class Config:
        from_attributes = True


class CheckoutRequest(BaseModel):
    plan_id: str


class CheckoutResponse(BaseModel):
    checkout_url: str


# === Usage ===

class UsageResponse(BaseModel):
    messages_today: int
    smart_messages_today: int
    deep_messages_today: int
    messages_limit: int
    smart_limit: int
    deep_limit: int


# === Admin ===

class AdminDashboardResponse(BaseModel):
    total_users: int
    active_users_today: int
    active_users_week: int
    total_messages_today: int
    total_conversations: int
    revenue_mrr: float
    subscriptions_by_plan: dict
    top_models: list[dict]
    error_rate: float
