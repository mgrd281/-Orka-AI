"""Subscription API routes — Plans, Checkout, Webhooks."""

import logging

from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.config import settings
from app.core.security import get_current_user
from app.models.user import User
from app.models.subscription import Subscription, Plan
from app.schemas.api import (
    PlanResponse,
    SubscriptionResponse,
    CheckoutRequest,
    CheckoutResponse,
)

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/plans", response_model=list[PlanResponse])
async def list_plans(
    lang: str = "de",
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Plan).where(Plan.is_active == True).order_by(Plan.sort_order)
    )
    plans = result.scalars().all()

    response = []
    for plan in plans:
        display_name = getattr(plan, f"display_name_{lang}", plan.display_name_de)
        description = getattr(plan, f"description_{lang}", plan.description_de)
        response.append(
            PlanResponse(
                id=plan.id,
                name=plan.name,
                display_name=display_name,
                description=description,
                price_monthly_eur=plan.price_monthly_eur,
                messages_per_day=plan.messages_per_day,
                smart_messages_per_day=plan.smart_messages_per_day,
                deep_messages_per_day=plan.deep_messages_per_day,
                file_upload_enabled=plan.file_upload_enabled,
                conversation_retention_days=plan.conversation_retention_days,
                priority_speed=plan.priority_speed,
                reasoning_view_full=plan.reasoning_view_full,
                export_enabled=plan.export_enabled,
            )
        )
    return response


@router.get("/current", response_model=SubscriptionResponse | None)
async def get_current_subscription(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Subscription)
        .where(Subscription.user_id == user.id)
        .where(Subscription.status == "active")
    )
    subscription = result.scalar_one_or_none()
    if not subscription:
        return None

    plan_result = await db.execute(select(Plan).where(Plan.id == subscription.plan_id))
    plan = plan_result.scalar_one_or_none()

    return SubscriptionResponse(
        plan=PlanResponse(
            id=plan.id,
            name=plan.name,
            display_name=plan.display_name_de,
            description=plan.description_de,
            price_monthly_eur=plan.price_monthly_eur,
            messages_per_day=plan.messages_per_day,
            smart_messages_per_day=plan.smart_messages_per_day,
            deep_messages_per_day=plan.deep_messages_per_day,
            file_upload_enabled=plan.file_upload_enabled,
            conversation_retention_days=plan.conversation_retention_days,
            priority_speed=plan.priority_speed,
            reasoning_view_full=plan.reasoning_view_full,
            export_enabled=plan.export_enabled,
        ),
        status=subscription.status,
        current_period_end=subscription.current_period_end,
    )


@router.post("/checkout", response_model=CheckoutResponse)
async def create_checkout(
    req: CheckoutRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Create a Stripe checkout session."""
    if not settings.stripe_secret_key:
        raise HTTPException(status_code=503, detail="Zahlungssystem wird konfiguriert")

    import stripe
    stripe.api_key = settings.stripe_secret_key

    plan_result = await db.execute(select(Plan).where(Plan.id == req.plan_id))
    plan = plan_result.scalar_one_or_none()
    if not plan or not plan.stripe_price_id:
        raise HTTPException(status_code=404, detail="Plan nicht gefunden")

    try:
        session = stripe.checkout.Session.create(
            customer_email=user.email,
            mode="subscription",
            line_items=[{"price": plan.stripe_price_id, "quantity": 1}],
            success_url=f"{settings.frontend_url}/subscription/success?session_id={{CHECKOUT_SESSION_ID}}",
            cancel_url=f"{settings.frontend_url}/subscription/cancel",
            metadata={"user_id": user.id, "plan_id": plan.id},
        )
        return CheckoutResponse(checkout_url=session.url)
    except stripe.error.StripeError as e:
        logger.error(f"Stripe error: {e}")
        raise HTTPException(status_code=500, detail="Fehler beim Erstellen der Zahlungssitzung")


@router.post("/webhook", status_code=200)
async def stripe_webhook(
    request: Request,
    db: AsyncSession = Depends(get_db),
):
    """Handle Stripe webhook events."""
    if not settings.stripe_secret_key or not settings.stripe_webhook_secret:
        raise HTTPException(status_code=503, detail="Webhook nicht konfiguriert")

    import stripe
    stripe.api_key = settings.stripe_secret_key

    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.stripe_webhook_secret
        )
    except (ValueError, stripe.error.SignatureVerificationError):
        raise HTTPException(status_code=400, detail="Ungültige Webhook-Signatur")

    if event["type"] == "checkout.session.completed":
        session = event["data"]["object"]
        user_id = session["metadata"]["user_id"]
        plan_id = session["metadata"]["plan_id"]

        subscription = Subscription(
            user_id=user_id,
            plan_id=plan_id,
            status="active",
            stripe_customer_id=session.get("customer"),
            stripe_subscription_id=session.get("subscription"),
        )
        db.add(subscription)

    elif event["type"] == "customer.subscription.deleted":
        stripe_sub_id = event["data"]["object"]["id"]
        result = await db.execute(
            select(Subscription).where(Subscription.stripe_subscription_id == stripe_sub_id)
        )
        sub = result.scalar_one_or_none()
        if sub:
            sub.status = "canceled"

    return {"status": "ok"}


@router.post("/cancel", status_code=200)
async def cancel_subscription(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Subscription)
        .where(Subscription.user_id == user.id)
        .where(Subscription.status == "active")
    )
    subscription = result.scalar_one_or_none()
    if not subscription:
        raise HTTPException(status_code=404, detail="Kein aktives Abonnement gefunden")

    if subscription.stripe_subscription_id and settings.stripe_secret_key:
        import stripe
        stripe.api_key = settings.stripe_secret_key
        try:
            stripe.Subscription.modify(
                subscription.stripe_subscription_id,
                cancel_at_period_end=True,
            )
        except stripe.error.StripeError as e:
            logger.error(f"Stripe cancel error: {e}")

    subscription.status = "canceled"
    return {"message": "Abonnement wird zum Ende der Laufzeit gekündigt"}
