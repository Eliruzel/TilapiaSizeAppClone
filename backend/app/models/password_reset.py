from datetime import datetime, timezone
from sqlmodel import SQLModel, Field

def utc_now():
    return datetime.now(timezone.utc)

class PasswordReset(SQLModel, table=True):
    __tablename__ = "password_resets"

    id: int | None = Field(
        default=None,
        primary_key=True,
    )

    email: str = Field(
        index=True,
        unique=True,
    )

    # Store a hash of the reset OTP, not the code.
    otp_hash: str

    # OTP validity and resend limits.
    otp_expires_at: datetime
    resend_available_at: datetime

    # Number of incorrect attempts.
    failed_attempts: int = Field(default=0)

    created_at: datetime = Field(
        default_factory=utc_now,
    )
