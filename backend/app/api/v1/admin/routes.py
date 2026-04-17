"""Admin API routes — Dashboard, Analytics, User Management."""

from datetime import datetime, timezone, timedelta, date

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.core.database import get_db
from app.core.security import get_admin_user
from app.models.user import User
from app.models.conversation import Conversation
from app.models.message import Message
from app.models.subscription import Subscription, Plan
from app.models.usage import UsageTracking
from app.schemas.api import AdminDashboardResponse

router = APIRouter()


@router.get("/dashboard", response_model=AdminDashboardResponse)
async def get_dashboard(
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_admin_user),
):
    now = datetime.now(timezone.utc)
    today = date.today()
    week_ago = now - timedelta(days=7)

    # Total users
    total_users_result = await db.execute(select(func.count(User.id)))
    total_users = total_users_result.scalar() or 0

    # Active users today
    active_today_result = await db.execute(
        select(func.count(func.distinct(UsageTracking.user_id)))
        .where(UsageTracking.date == today)
    )
    active_today = active_today_result.scalar() or 0

    # Active users this week
    active_week_result = await db.execute(
        select(func.count(func.distinct(UsageTracking.user_id)))
        .where(UsageTracking.date >= today - timedelta(days=7))
    )
    active_week = active_week_result.scalar() or 0

    # Messages today
    messages_today_result = await db.execute(
        select(func.sum(UsageTracking.total_messages))
        .where(UsageTracking.date == today)
    )
    messages_today = messages_today_result.scalar() or 0

    # Total conversations
    total_convs_result = await db.execute(select(func.count(Conversation.id)))
    total_convs = total_convs_result.scalar() or 0

    # Subscription analytics
    sub_stats_result = await db.execute(
        select(Plan.name, func.count(Subscription.id))
        .join(Plan)
        .where(Subscription.status == "active")
        .group_by(Plan.name)
    )
    sub_by_plan = {name: count for name, count in sub_stats_result.all()}

    # Revenue (approximate MRR)
    revenue_result = await db.execute(
        select(func.sum(Plan.price_monthly_eur))
        .join(Subscription, Subscription.plan_id == Plan.id)
        .where(Subscription.status == "active")
    )
    revenue_mrr = revenue_result.scalar() or 0.0

    return AdminDashboardResponse(
        total_users=total_users,
        active_users_today=active_today,
        active_users_week=active_week,
        total_messages_today=messages_today,
        total_conversations=total_convs,
        revenue_mrr=float(revenue_mrr),
        subscriptions_by_plan=sub_by_plan,
        top_models=[],  # TODO: aggregate from agent_steps
        error_rate=0.0,  # TODO: from monitoring
    )
