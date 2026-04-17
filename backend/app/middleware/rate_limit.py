"""Rate limiting middleware for Orka AI."""

import time
from collections import defaultdict
from fastapi import Request, HTTPException
from starlette.middleware.base import BaseHTTPMiddleware

from app.core.config import settings


class RateLimitMiddleware(BaseHTTPMiddleware):
    """Simple in-memory rate limiter. Use Redis in production."""

    def __init__(self, app):
        super().__init__(app)
        self._requests: dict[str, list[float]] = defaultdict(list)

    async def dispatch(self, request: Request, call_next):
        # Skip rate limiting for health checks and webhooks
        if request.url.path in ("/health", "/api/v1/subscriptions/webhook"):
            return await call_next(request)

        # Get client identifier
        client_ip = request.client.host if request.client else "unknown"
        auth_header = request.headers.get("authorization", "")
        client_key = auth_header if auth_header else client_ip

        now = time.time()
        window = 60  # 1 minute window

        # Clean old entries
        self._requests[client_key] = [
            ts for ts in self._requests[client_key] if now - ts < window
        ]

        if len(self._requests[client_key]) >= settings.rate_limit_per_minute:
            raise HTTPException(
                status_code=429,
                detail="Zu viele Anfragen. Bitte versuchen Sie es in einer Minute erneut.",
            )

        self._requests[client_key].append(now)
        return await call_next(request)
