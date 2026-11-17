from datetime import datetime, timezone
from sqlmodel import SQLModel, Field

def utc_now():
    return datetime.now(timezone.utc)


class EmailOTP(SQLModel, table=True):
    __tablename__ = "email_otps"

    id: int | None = Field(
        default=None,
        primary_key=True
    )

    email: str = Field(
        index=True,
        unique=True
    )

    # Store a secure hash, never the actual OTP.
    code_hash: str

    # OTP expires after 2 minutes.
    expires_at: datetime

    # New OTP can be requested after 60 seconds.
    resend_available_at: datetime

    # Maximum of 5 failed verification attempts.
    failed_attempts: int = Field(default=0)

    created_at: datetime = Field(
        default_factory=utc_now
    )
