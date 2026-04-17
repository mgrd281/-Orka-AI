from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # App
    app_env: str = "development"
    app_debug: bool = False
    app_secret_key: str = "change-me"
    app_url: str = "http://localhost:8000"
    frontend_url: str = "http://localhost:3000"

    # Database
    database_url: str = "postgresql+asyncpg://orka:orka@localhost:5432/orka_ai"
    database_echo: bool = False

    # Redis
    redis_url: str = "redis://localhost:6379/0"

    # JWT
    jwt_secret_key: str = "change-me"
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 30
    jwt_refresh_token_expire_days: int = 30

    # AI Providers
    openai_api_key: Optional[str] = None
    anthropic_api_key: Optional[str] = None

    # Default Models
    default_fast_model: str = "gpt-4o-mini"
    default_smart_model: str = "gpt-4o"
    default_deep_model: str = "claude-sonnet-4-20250514"

    # Stripe
    stripe_secret_key: Optional[str] = None
    stripe_webhook_secret: Optional[str] = None
    stripe_pro_price_id: Optional[str] = None
    stripe_premium_price_id: Optional[str] = None

    # Analytics
    posthog_api_key: Optional[str] = None
    posthog_host: str = "https://eu.posthog.com"

    # Sentry
    sentry_dsn: Optional[str] = None

    # Storage
    s3_bucket: Optional[str] = None
    s3_region: str = "eu-central-1"
    s3_access_key: Optional[str] = None
    s3_secret_key: Optional[str] = None

    # Rate Limits
    rate_limit_per_minute: int = 30
    rate_limit_per_day_free: int = 15
    rate_limit_per_day_pro: int = 100

    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()
