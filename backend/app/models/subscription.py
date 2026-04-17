import uuid
from datetime import datetime, timezone

from sqlalchemy import String, DateTime, ForeignKey, Integer, Float, Boolean
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base


class Plan(Base):
    __tablename__ = "plans"

    id: Mapped[str] = mapped_column(
        UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    name: Mapped[str] = mapped_column(String(50), nullable=False, unique=True)
    display_name_de: Mapped[str] = mapped_column(String(100), nullable=False)
    display_name_en: Mapped[str] = mapped_column(String(100), nullable=False)
    display_name_ar: Mapped[str] = mapped_column(String(100), nullable=False)
    description_de: Mapped[str] = mapped_column(String(500), nullable=False)
    description_en: Mapped[str] = mapped_column(String(500), nullable=False)
    description_ar: Mapped[str] = mapped_column(String(500), nullable=False)
    price_monthly_eur: Mapped[float] = mapped_column(Float, default=0.0)
    stripe_price_id: Mapped[str | None] = mapped_column(String(255), nullable=True)

    # Limits
    messages_per_day: Mapped[int] = mapped_column(Integer, default=15)
    smart_messages_per_day: Mapped[int] = mapped_column(Integer, default=5)
    deep_messages_per_day: Mapped[int] = mapped_column(Integer, default=0)
    file_upload_enabled: Mapped[bool] = mapped_column(Boolean, default=False)
    conversation_retention_days: Mapped[int] = mapped_column(Integer, default=7)
    priority_speed: Mapped[bool] = mapped_column(Boolean, default=False)
    reasoning_view_full: Mapped[bool] = mapped_column(Boolean, default=False)
    export_enabled: Mapped[bool] = mapped_column(Boolean, default=False)

    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    sort_order: Mapped[int] = mapped_column(Integer, default=0)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    subscriptions = relationship("Subscription", back_populates="plan")


class Subscription(Base):
    __tablename__ = "subscriptions"

    id: Mapped[str] = mapped_column(
        UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    user_id: Mapped[str] = mapped_column(
        UUID(as_uuid=False), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True
    )
    plan_id: Mapped[str] = mapped_column(
        UUID(as_uuid=False), ForeignKey("plans.id"), nullable=False
    )
    status: Mapped[str] = mapped_column(
        String(20), default="active"  # active, canceled, past_due, expired
    )
    stripe_customer_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    stripe_subscription_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    current_period_start: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    current_period_end: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    canceled_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    user = relationship("User", back_populates="subscription")
    plan = relationship("Plan", back_populates="subscriptions")
