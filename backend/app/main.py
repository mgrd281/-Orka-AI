"""
Orka AI — FastAPI Application Entry Point
"""

import logging
from contextlib import asynccontextmanager

import sentry_sdk
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware

from app.core.config import settings
from app.api.v1.router import api_router
from app.middleware.rate_limit import RateLimitMiddleware

# Configure logging
logging.basicConfig(
    level=logging.DEBUG if settings.app_debug else logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)
logger = logging.getLogger("orka")

# Initialize Sentry
if settings.sentry_dsn:
    sentry_sdk.init(
        dsn=settings.sentry_dsn,
        traces_sample_rate=0.1,
        profiles_sample_rate=0.1,
        environment=settings.app_env,
    )


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("🐋 Orka AI starting up...")
    yield
    logger.info("🐋 Orka AI shutting down...")


app = FastAPI(
    title="Orka AI",
    description="Koordinierte Intelligenz — Multi-Agent AI Platform",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs" if settings.app_debug else None,
    redoc_url="/redoc" if settings.app_debug else None,
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        settings.frontend_url,
        "http://localhost:3000",
        "http://localhost:8080",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Rate limiting
app.add_middleware(RateLimitMiddleware)

# Include API routes
app.include_router(api_router)


@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "orka-ai-backend",
        "version": "1.0.0",
    }
