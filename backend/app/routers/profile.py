import jwt
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, ConfigDict, Field, field_validator
from sqlmodel import Session, select

from app.database.connection import get_session
from app.models.farmer_profile import FarmerProfile
from app.models.user import User
from app.routers import auth

router = APIRouter(prefix="/profile", tags=["Profile"])
bearer = HTTPBearer(auto_error=False)


def current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer),
    session: Session = Depends(get_session),
) -> User:
    if credentials is None:
        raise HTTPException(401, "Please log in again.")
    if not auth.JWT_SECRET_KEY:
        raise HTTPException(503, "Authentication is not configured.")
    try:
        payload = jwt.decode(
            credentials.credentials, auth.JWT_SECRET_KEY,
            algorithms=[auth.JWT_ALGORITHM],
            options={"require": ["sub", "iat", "exp"]},
        )
        if payload.get("purpose") is not None:
            raise ValueError("Not an access token")
        user_id = int(payload["sub"])
    except (jwt.InvalidTokenError, ValueError, TypeError, KeyError):
        raise HTTPException(401, "Your session has expired. Please log in again.")
    user = session.get(User, user_id)
    if user is None or not user.is_verified:
        raise HTTPException(401, "Please log in again.")
    return user


class ProfileUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")
    full_name: str = Field(min_length=1, max_length=120)
    farm_name: str = Field(default="", max_length=160)
    farm_location: str = Field(default="", max_length=240)

    @field_validator("full_name", "farm_name", "farm_location", mode="before")
    @classmethod
    def strip_text(cls, value):
        return value.strip() if isinstance(value, str) else value


class PasswordUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")
    current_password: str = Field(min_length=1, max_length=256)
    new_password: str = Field(min_length=8, max_length=256)


def profile_data(user: User, profile: FarmerProfile | None):
    return {
        "id": user.id, "full_name": user.full_name, "email": user.email,
        "farm_name": profile.farm_name if profile else "",
        "farm_location": profile.farm_location if profile else "",
    }


@router.get("")
def get_profile(user: User = Depends(current_user), session: Session = Depends(get_session)):
    return profile_data(user, session.get(FarmerProfile, user.id))


@router.put("")
def update_profile(data: ProfileUpdate, user: User = Depends(current_user),
                   session: Session = Depends(get_session)):
    # Serialize concurrent updates and the initial profile-row insert.
    user = session.exec(select(User).where(User.id == user.id).with_for_update()).one()
    profile = session.get(FarmerProfile, user.id)
    if profile is None:
        profile = FarmerProfile(user_id=user.id)
    user.full_name = data.full_name
    profile.farm_name = data.farm_name
    profile.farm_location = data.farm_location
    session.add(user)
    session.add(profile)
    session.commit()
    session.refresh(user)
    session.refresh(profile)
    return profile_data(user, profile)


@router.post("/password")
def change_password(data: PasswordUpdate, user: User = Depends(current_user),
                    session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.id == user.id).with_for_update()).one()
    if not auth.password_hasher.verify(data.current_password, user.password_hash):
        raise HTTPException(400, "Current password is incorrect.")
    if data.new_password == data.current_password:
        raise HTTPException(422, "Choose a different new password.")
    if not data.new_password.strip():
        raise HTTPException(422, "The new password cannot contain only spaces.")
    user.password_hash = auth.password_hasher.hash(data.new_password)
    session.add(user)
    session.commit()
    return {"message": "Password updated successfully."}
