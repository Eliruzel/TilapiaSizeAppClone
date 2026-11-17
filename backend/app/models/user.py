
from sqlmodel import SQLModel, Field


class User(SQLModel, table=True):
    __tablename__ = "users"

    # Unique user ID
    id: int | None = Field(default=None, primary_key=True)

    # Account information
    full_name: str
    email: str = Field(unique=True, index=True)
    password_hash: str

    # Email verification
    is_verified: bool = Field(default=False)

    # OTP verification information
    otp_hash: str | None = Field(default=None)
    otp_expires_at: int | None = Field(default=None)
    resend_available_at: int | None = Field(default=None)
    otp_attempts: int = Field(default=0)

    # User role, default is "farmer"
    role: str = Field(default="farmer", max_length=20)
