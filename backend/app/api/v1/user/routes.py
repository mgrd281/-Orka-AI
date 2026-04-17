"""User API routes — Profile, Preferences, Usage."""

from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.usage import UsageTracking
from app.models.subscription import Subscription, Plan
from app.schemas.api import UserProfile, UpdateProfileRequest, UsageResponse

router = APIRouter()


@router.get("/profile", response_model=UserProfile)
async def get_profile(user: User = Depends(get_current_user)):
    return user


@router.patch("/profile", response_model=UserProfile)
async def update_profile(
    req: UpdateProfileRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    if req.full_name is not None:
        user.full_name = req.full_name
    if req.avatar_url is not None:
        user.avatar_url = req.avatar_url
    if req.language is not None:
        if req.language not in ("de", "en", "ar"):
            raise HTTPException(status_code=400, detail="Nicht unterstützte Sprache")
        user.language = req.language
    if req.theme is not None:
        if req.theme not in ("dark", "light", "system"):
            raise HTTPException(status_code=400, detail="Ungültiges Theme")
        user.theme = req.theme
    if req.default_mode is not None:
        if req.default_mode not in ("fast", "smart", "deep"):
            raise HTTPException(status_code=400, detail="Ungültiger Modus")
        user.default_mode = req.default_mode

    return user


@router.get("/usage", response_model=UsageResponse)
async def get_usage(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    today = date.today()

    # Get today's usage
    result = await db.execute(
        select(UsageTracking)
        .where(UsageTracking.user_id == user.id)
        .where(UsageTracking.date == today)
    )
    usage = result.scalar_one_or_none()

    # Get user's plan limits
    sub_result = await db.execute(
        select(Subscription)
        .where(Subscription.user_id == user.id)
        .where(Subscription.status == "active")
    )
    subscription = sub_result.scalar_one_or_none()

    # Default free plan limits
    messages_limit = 15
    smart_limit = 5
    deep_limit = 0

    if subscription:
        plan_result = await db.execute(select(Plan).where(Plan.id == subscription.plan_id))
        plan = plan_result.scalar_one_or_none()
        if plan:
            messages_limit = plan.messages_per_day
            smart_limit = plan.smart_messages_per_day
            deep_limit = plan.deep_messages_per_day

    return UsageResponse(
        messages_today=usage.total_messages if usage else 0,
        smart_messages_today=usage.messages_smart if usage else 0,
        deep_messages_today=usage.messages_deep if usage else 0,
        messages_limit=messages_limit,
        smart_limit=smart_limit,
        deep_limit=deep_limit,
    )
