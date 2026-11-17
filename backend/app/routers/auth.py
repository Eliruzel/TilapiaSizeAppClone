
import hashlib
import hmac
import os
import secrets
from datetime import datetime, timedelta, timezone

import jwt
from dotenv import load_dotenv
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
from pwdlib import PasswordHash
from sqlmodel import Session, select

from app.database.connection import get_session
from app.models.pending_registration import PendingRegistration
from app.models.user import User

from app.models.password_reset import PasswordReset
from app.services.email_service import (
    send_otp_email,
    send_password_reset_email,
)


load_dotenv()

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)

password_hasher = PasswordHash.recommended()

JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
JWT_ALGORITHM = "HS256"
JWT_EXPIRATION_MINUTES = 7 * 24 * 60

OTP_EXPIRATION_SECONDS = 120
OTP_RESEND_COOLDOWN_SECONDS = 60
OTP_MAX_ATTEMPTS = 5


class RegisterRequest(BaseModel):
    full_name: str = Field(min_length=1)
    email: EmailStr
    password: str = Field(min_length=8)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class VerifyOTPRequest(BaseModel):
    email: EmailStr
    otp_code: str = Field(
        min_length=6,
        max_length=6,
        pattern=r"^\d{6}$",
    )


class ResendOTPRequest(BaseModel):
    email: EmailStr


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def normalize_email(email: str) -> str:
    return str(email).strip().lower()


def hash_otp(email: str, code: str) -> str:
    if not JWT_SECRET_KEY:
        raise RuntimeError(
            "JWT_SECRET_KEY is missing from backend/.env"
        )

    return hmac.new(
        JWT_SECRET_KEY.encode("utf-8"),
        f"{email}:{code}".encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()


def generate_otp() -> str:
    return f"{secrets.randbelow(1000000):06d}"


def create_access_token(user_id: int) -> str:
    if not JWT_SECRET_KEY:
        raise RuntimeError(
            "JWT_SECRET_KEY is missing from backend/.env"
        )

    now = utc_now()

    return jwt.encode(
        {
            "sub": str(user_id),
            "iat": now,
            "exp": now + timedelta(
                minutes=JWT_EXPIRATION_MINUTES
            ),
        },
        JWT_SECRET_KEY,
        algorithm=JWT_ALGORITHM,
    )


def send_verification_email(email: str, code: str) -> None:
    try:
        send_otp_email(
            recipient_email=email,
            otp_code=code,
        )
    except Exception as error:
        print(
            "OTP email delivery failed:",
            type(error).__name__,
        )

        raise HTTPException(
            status_code=503,
            detail=(
                "Unable to send verification email. "
                "Please try again later."
            ),
        ) from error


# STEP 1: START REGISTRATION
# This does NOT create a User account.
@router.post(
    "/register",
    status_code=status.HTTP_201_CREATED,
)
def register_user(
    data: RegisterRequest,
    session: Session = Depends(get_session),
):
    email = normalize_email(data.email)
    full_name = data.full_name.strip()

    if not full_name:
        raise HTTPException(
            status_code=422,
            detail="Full name is required.",
        )

    existing_user = session.exec(
        select(User).where(User.email == email)
    ).first()

    if existing_user is not None:
        raise HTTPException(
            status_code=409,
            detail="Email is already registered.",
        )

    now = utc_now()

    pending = session.exec(
        select(PendingRegistration).where(
            PendingRegistration.email == email
        )
    ).first()

    if pending is not None:
        if now < pending.resend_available_at:
            raise HTTPException(
                status_code=429,
                detail=(
                    "Please wait 60 seconds before "
                    "requesting another verification code."
                ),
            )

        # Replace an unfinished registration.
        pending.full_name = full_name
        pending.password_hash = password_hasher.hash(
            data.password
        )
    else:
        pending = PendingRegistration(
            email=email,
            full_name=full_name,
            password_hash=password_hasher.hash(
                data.password
            ),
            otp_hash="",
            otp_expires_at=now,
            resend_available_at=now,
            failed_attempts=0,
        )

    code = generate_otp()

    pending.otp_hash = hash_otp(email, code)
    pending.otp_expires_at = now + timedelta(
        seconds=OTP_EXPIRATION_SECONDS
    )
    pending.resend_available_at = now + timedelta(
        seconds=OTP_RESEND_COOLDOWN_SECONDS
    )
    pending.failed_attempts = 0

    session.add(pending)
    session.commit()

    # Only the pending registration is saved.
    # No row is inserted into the User table.
    send_verification_email(email, code)

    return {
        "message": "Verification code sent to your email.",
        "email": email,
        "otp_sent": True,
        "otp_expires_in": OTP_EXPIRATION_SECONDS,
        "is_verified": False,
    }


# STEP 2: VERIFY OTP
# Only a correct OTP creates the real User account.
@router.post("/verify-otp")
def verify_email_otp(
    data: VerifyOTPRequest,
    session: Session = Depends(get_session),
):
    email = normalize_email(data.email)

    pending = session.exec(
        select(PendingRegistration).where(
            PendingRegistration.email == email
        )
    ).first()

    if pending is None:
        raise HTTPException(
            status_code=404,
            detail=(
                "No pending registration found. "
                "Please register again."
            ),
        )

    now = utc_now()

    if now >= pending.otp_expires_at:
        raise HTTPException(
            status_code=400,
            detail="OTP expired. Please request a new code.",
        )

    if pending.failed_attempts >= OTP_MAX_ATTEMPTS:
        raise HTTPException(
            status_code=429,
            detail=(
                "Maximum OTP attempts reached. "
                "Please request a new code."
            ),
        )

    entered_hash = hash_otp(
        email,
        data.otp_code,
    )

    if not hmac.compare_digest(
        entered_hash,
        pending.otp_hash,
    ):
        pending.failed_attempts += 1
        remaining = (
            OTP_MAX_ATTEMPTS - pending.failed_attempts
        )

        session.add(pending)
        session.commit()

        raise HTTPException(
            status_code=400,
            detail=(
                f"Incorrect OTP. "
                f"{remaining} attempts remaining."
            ),
        )

    existing_user = session.exec(
        select(User).where(User.email == email)
    ).first()

    if existing_user is not None:
        raise HTTPException(
            status_code=409,
            detail="This email is already registered.",
        )

    # CORRECT OTP: create the real verified account.
    new_user = User(
        full_name=pending.full_name,
        email=pending.email,
        password_hash=pending.password_hash,
        is_verified=True,
    )

    session.add(new_user)

    # Remove temporary registration details.
    session.delete(pending)

    # Both operations are committed together.
    session.commit()

    return {
        "message": "Email verified. Account created successfully.",
        "email": email,
        "is_verified": True,
    }


# STEP 3: RESEND OTP
@router.post("/resend-otp")
def resend_registration_otp(
    data: ResendOTPRequest,
    session: Session = Depends(get_session),
):
    email = normalize_email(data.email)

    pending = session.exec(
        select(PendingRegistration).where(
            PendingRegistration.email == email
        )
    ).first()

    if pending is None:
        raise HTTPException(
            status_code=404,
            detail="No pending registration found.",
        )

    now = utc_now()

    if now < pending.resend_available_at:
        raise HTTPException(
            status_code=429,
            detail=(
                "Please wait before requesting "
                "another verification code."
            ),
        )

    code = generate_otp()

    pending.otp_hash = hash_otp(email, code)
    pending.otp_expires_at = now + timedelta(
        seconds=OTP_EXPIRATION_SECONDS
    )
    pending.resend_available_at = now + timedelta(
        seconds=OTP_RESEND_COOLDOWN_SECONDS
    )
    pending.failed_attempts = 0

    session.add(pending)
    session.commit()

    send_verification_email(email, code)

    return {
        "message": "A new verification code has been sent.",
        "email": email,
        "otp_expires_in": OTP_EXPIRATION_SECONDS,
    }


# LOGIN: ONLY VERIFIED USERS EXIST IN THE USER TABLE.
@router.post("/login")
def login_user(
    data: LoginRequest,
    session: Session = Depends(get_session),
):
    email = normalize_email(data.email)

    user = session.exec(
        select(User).where(User.email == email)
    ).first()

    if user is None:
        raise HTTPException(
            status_code=404,
            detail=(
                "Account not found. "
                "Please create an account first."
            ),
        )

    if not password_hasher.verify(
        data.password,
        user.password_hash,
    ):
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password.",
        )

    if not user.is_verified:
        raise HTTPException(
            status_code=403,
            detail=(
                "Your email is not verified yet. "
                "Please verify your account first."
            ),
        )

    access_token = create_access_token(user.id)

    return {
        "message": "Login successful.",
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "full_name": user.full_name,
            "email": user.email,
            "is_verified": user.is_verified,
        },
    }

# FORGOT PASSWORD - REQUEST RESET OTP
class ForgotPasswordRequest(BaseModel):
    email: EmailStr


@router.post("/forgot-password")
def forgot_password(
    data: ForgotPasswordRequest,
    session: Session = Depends(get_session),
):
    email = str(data.email).strip().lower()

    # Same response whether the email exists or not.
    response_message = {
        "message": (
            "If an account exists for this email, "
            "a password reset code has been sent."
        )
    }

    user = session.exec(
        select(User).where(User.email == email)
    ).first()

    if user is None:
        return response_message

    now = datetime.now(timezone.utc)

    # Find any previous password reset request.
    reset = session.exec(
        select(PasswordReset).where(
            PasswordReset.email == email
        )
    ).first()

    # Enforce the 60-second resend cooldown.
    if reset is not None:
        if now < reset.resend_available_at:
            return response_message

    if not JWT_SECRET_KEY:
        raise RuntimeError(
            "JWT_SECRET_KEY is missing from backend/.env"
        )

    # Generate a random six-digit OTP.
    code = f"{secrets.randbelow(1000000):06d}"

    # Hash OTP before saving it.
    code_hash = hmac.new(
        JWT_SECRET_KEY.encode("utf-8"),
        f"password-reset:{email}:{code}".encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()

    if reset is None:
        reset = PasswordReset(
            email=email,
            otp_hash=code_hash,
            otp_expires_at=now + timedelta(minutes=2),
            resend_available_at=now + timedelta(seconds=60),
            failed_attempts=0,
        )
    else:
        reset.otp_hash = code_hash
        reset.otp_expires_at = now + timedelta(minutes=2)
        reset.resend_available_at = now + timedelta(seconds=60)
        reset.failed_attempts = 0

    session.add(reset)
    session.commit()

    # Send your professional TilapiaSize reset email.
    try:
        send_password_reset_email(
            recipient_email=email,
            otp_code=code,
        )
    except Exception as error:
        # Do not expose account existence to the caller.
        print(
            "Password reset email failed:",
            type(error).__name__,
        )

    return response_message


# ==========================================
# PASSWORD RESET - VERIFY EMAIL OTP
# ==========================================

class VerifyPasswordResetRequest(BaseModel):
    email: EmailStr
    otp_code: str = Field(
        min_length=6,
        max_length=6,
        pattern=r"^\d{6}$",
    )


@router.post("/verify-reset-otp")
def verify_password_reset_otp(
    data: VerifyPasswordResetRequest,
    session: Session = Depends(get_session),
):
    email = str(data.email).strip().lower()

    reset = session.exec(
        select(PasswordReset).where(
            PasswordReset.email == email
        )
    ).first()

    if reset is None:
        raise HTTPException(
            status_code=400,
            detail="Invalid or expired reset code.",
        )

    now = datetime.now(timezone.utc)

    # The OTP is valid for only 2 minutes.
    if now >= reset.otp_expires_at:
        raise HTTPException(
            status_code=400,
            detail="OTP expired. Please request a new code.",
        )

    # Maximum of 5 incorrect attempts.
    if reset.failed_attempts >= 5:
        raise HTTPException(
            status_code=429,
            detail="Too many attempts. Request a new code.",
        )

    if not JWT_SECRET_KEY:
        raise RuntimeError(
            "JWT_SECRET_KEY is missing."
        )

    # Use the same hashing method as
    # the forgot-password endpoint.
    entered_hash = hmac.new(
        JWT_SECRET_KEY.encode("utf-8"),
        f"password-reset:{email}:{data.otp_code}".encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()

    if not hmac.compare_digest(
        entered_hash,
        reset.otp_hash,
    ):
        reset.failed_attempts += 1
        remaining = 5 - reset.failed_attempts

        session.add(reset)
        session.commit()

        raise HTTPException(
            status_code=400,
            detail=(
                f"Incorrect OTP. "
                f"{remaining} attempts remaining."
            ),
        )

    # Correct OTP: issue a short-lived token
    # that permits changing the password.
    # The token is valid for 5 minutes.
    reset_token = jwt.encode(
        {
            "sub": email,
            "purpose": "password_reset",
            "otp_hash": reset.otp_hash,
            "iat": now,
            "exp": now + timedelta(minutes=5),
        },
        JWT_SECRET_KEY,
        algorithm="HS256",
    )

    return {
        "message": "Reset code verified successfully.",
        "reset_token": reset_token,
        "expires_in": 300,
    }


# ==========================================
# PASSWORD RESET - SET NEW PASSWORD
# ==========================================

class ResetPasswordRequest(BaseModel):
    reset_token: str
    new_password: str = Field(min_length=8)


@router.post("/reset-password")
def reset_password(
    data: ResetPasswordRequest,
    session: Session = Depends(get_session),
):
    if not JWT_SECRET_KEY:
        raise RuntimeError(
            "JWT_SECRET_KEY is missing."
        )

    try:
        payload = jwt.decode(
            data.reset_token,
            JWT_SECRET_KEY,
            algorithms=["HS256"],
        )
    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=400,
            detail=(
                "Password reset session expired or invalid. "
                "Please request a new code."
            ),
        )

    if payload.get("purpose") != "password_reset":
        raise HTTPException(
            status_code=400,
            detail="Invalid password reset token.",
        )

    email = payload.get("sub")
    token_otp_hash = payload.get("otp_hash")

    if not isinstance(email, str) or not isinstance(
        token_otp_hash, str
    ):
        raise HTTPException(
            status_code=400,
            detail="Invalid password reset token.",
        )

    reset = session.exec(
        select(PasswordReset).where(
            PasswordReset.email == email
        )
    ).first()

    if (
        reset is None
        or not hmac.compare_digest(
            token_otp_hash,
            reset.otp_hash,
        )
        or reset.failed_attempts >= 5
    ):
        raise HTTPException(
            status_code=400,
            detail="Password reset session is no longer valid.",
        )

    user = session.exec(
        select(User).where(User.email == email)
    ).first()

    if user is None:
        raise HTTPException(
            status_code=400,
            detail="Password reset session is no longer valid.",
        )

    # Hash the new password using Argon2.
    user.password_hash = password_hasher.hash(
        data.new_password
    )

    session.add(user)

    # Consume the reset request so the
    # reset token cannot be reused.
    session.delete(reset)

    session.commit()

    return {
        "message": "Password changed successfully.",
    }

