from datetime import datetime, timezone

from sqlmodel import SQLModel, Field


def utc_now():
    return datetime.now(timezone.utc)


class PendingRegistration(SQLModel, table=True):
    __tablename__ = "pending_registrations"

    id: int | None = Field(
        default=None,
        primary_key=True,
    )

    email: str = Field(
        index=True,
        unique=True,
    )

    full_name: str

    # Store the hashed password, never plain text.
    password_hash: str

    # Store the hashed OTP, never the actual code.
    otp_hash: str

    # OTP expires after 2 minutes.
    otp_expires_at: datetime

    # Resending is allowed after 60 seconds.
    resend_available_at: datetime

    # Maximum of 5 incorrect attempts.
    failed_attempts: int = Field(default=0)

    created_at: datetime = Field(
        default_factory=utc_now,
    )
