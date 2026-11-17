from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import SQLModel

from app.models.user import User
from app.models.password_reset import PasswordReset
from app.models.email_otp import EmailOTP
from app.models.pending_registration import PendingRegistration
from app.models.farmer_profile import FarmerProfile
from app.routers import auth, profile
from app.database.connection import engine




# Create database tables when FastAPI starts.
@asynccontextmanager
async def lifespan(app: FastAPI):
    SQLModel.metadata.create_all(engine)
    yield


app = FastAPI(
    title="TilapiaSize API",
    description="Backend API for TilapiaSize",
    version="1.0.0",
    lifespan=lifespan,
)


# Allow Flutter Web to connect during development.
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1):\d+",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register authentication routes.
app.include_router(auth.router)
app.include_router(profile.router)


@app.get("/")
def home():
    return {
        "message": "Welcome to TilapiaSize API",
        "status": "running",
    }

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
    }
