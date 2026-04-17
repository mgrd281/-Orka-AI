"""Auth API routes — Registration, Login, Social Auth, Token Refresh."""

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    decode_token,
)
from app.core.config import settings
from app.models.user import User
from app.schemas.api import (
    RegisterRequest,
    LoginRequest,
    TokenResponse,
    RefreshRequest,
    SocialAuthRequest,
    UserProfile,
)

router = APIRouter()


@router.post("/register", response_model=TokenResponse, status_code=201)
async def register(req: RegisterRequest, db: AsyncSession = Depends(get_db)):
    # Check existing user
    result = await db.execute(select(User).where(User.email == req.email))
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="E-Mail-Adresse bereits registriert")

    # Validate password strength
    if len(req.password) < 8:
        raise HTTPException(status_code=400, detail="Passwort muss mindestens 8 Zeichen lang sein")

    user = User(
        email=req.email,
        hashed_password=hash_password(req.password),
        full_name=req.full_name,
        language=req.language,
        auth_provider="email",
    )
    db.add(user)
    await db.flush()

    access_token = create_access_token(user.id)
    refresh_token = create_refresh_token(user.id)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=settings.jwt_access_token_expire_minutes * 60,
    )


@router.post("/login", response_model=TokenResponse)
async def login(req: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == req.email))
    user = result.scalar_one_or_none()

    if not user or not user.hashed_password or not verify_password(req.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Ungültige Anmeldedaten")

    if not user.is_active:
        raise HTTPException(status_code=403, detail="Konto deaktiviert")

    # Update last login
    user.last_login_at = datetime.now(timezone.utc)

    access_token = create_access_token(user.id)
    refresh_token = create_refresh_token(user.id)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=settings.jwt_access_token_expire_minutes * 60,
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(req: RefreshRequest, db: AsyncSession = Depends(get_db)):
    payload = decode_token(req.refresh_token)
    if payload.get("type") != "refresh":
        raise HTTPException(status_code=401, detail="Ungültiger Refresh-Token")

    user_id = payload.get("sub")
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user or not user.is_active:
        raise HTTPException(status_code=401, detail="Benutzer nicht gefunden")

    access_token = create_access_token(user.id)
    refresh_token = create_refresh_token(user.id)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=settings.jwt_access_token_expire_minutes * 60,
    )


@router.post("/social/{provider}", response_model=TokenResponse)
async def social_auth(provider: str, req: SocialAuthRequest, db: AsyncSession = Depends(get_db)):
    """Handle Google/Apple social authentication.
    
    In production, validate the token with the provider's API.
    """
    if provider not in ("google", "apple"):
        raise HTTPException(status_code=400, detail="Nicht unterstützter Anbieter")

    # TODO: Validate token with provider API
    # For now, this is a placeholder for the social auth flow
    raise HTTPException(
        status_code=501,
        detail="Social-Auth-Integration wird konfiguriert",
    )


@router.post("/logout", status_code=204)
async def logout():
    """Client-side logout — invalidate tokens on client."""
    return None
