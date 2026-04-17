from fastapi import APIRouter

from app.api.v1.auth.routes import router as auth_router
from app.api.v1.chat.routes import router as chat_router
from app.api.v1.user.routes import router as user_router
from app.api.v1.subscriptions.routes import router as sub_router
from app.api.v1.admin.routes import router as admin_router

api_router = APIRouter(prefix="/api/v1")

api_router.include_router(auth_router, prefix="/auth", tags=["Authentifizierung"])
api_router.include_router(chat_router, prefix="/chat", tags=["Chat"])
api_router.include_router(user_router, prefix="/user", tags=["Benutzer"])
api_router.include_router(sub_router, prefix="/subscriptions", tags=["Abonnements"])
api_router.include_router(admin_router, prefix="/admin", tags=["Administration"])
