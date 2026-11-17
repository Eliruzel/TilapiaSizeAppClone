from datetime import datetime, timedelta, timezone

import jwt
import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlalchemy.pool import StaticPool
from sqlmodel import SQLModel, Session, create_engine

from app.database.connection import get_session
from app.models.user import User
from app.models.farmer_profile import FarmerProfile
from app.routers import auth, profile


@pytest.fixture
def setup(monkeypatch):
    monkeypatch.setattr(auth, "JWT_SECRET_KEY", "isolated-test-key-32-characters-long")
    engine = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    SQLModel.metadata.create_all(engine)
    with Session(engine) as session:
        for name in ["first", "second"]:
            session.add(User(full_name=name, email=f"{name}@example.com", is_verified=True,
                             password_hash=auth.password_hasher.hash("old-password")))
        session.commit()
    app = FastAPI()
    app.include_router(profile.router)

    def sessions():
        with Session(engine) as session:
            yield session

    app.dependency_overrides[get_session] = sessions
    with TestClient(app) as client:
        yield client, engine, {"Authorization": f"Bearer {auth.create_access_token(1)}"}
    engine.dispose()


def test_authentication_is_required(setup):
    client, _, headers = setup
    assert client.get("/profile").status_code == 401
    now = datetime.now(timezone.utc)
    for claims in [
        {"sub": "1", "iat": now, "exp": now - timedelta(seconds=10)},
        {"sub": "1", "iat": now, "exp": now + timedelta(minutes=1), "purpose": "password_reset"},
        {"sub": "1", "iat": now},
    ]:
        token = jwt.encode(claims, auth.JWT_SECRET_KEY, algorithm="HS256")
        assert client.get("/profile", headers={"Authorization": f"Bearer {token}"}).status_code == 401
    assert client.get("/profile", headers=headers).status_code == 200


def test_updates_persist_and_are_isolated(setup):
    client, engine, headers = setup
    data = {"full_name": "  Updated Name  ", "farm_name": " Pond Farm ", "farm_location": " Town "}
    response = client.put("/profile", headers=headers, json=data)
    assert response.status_code == 200
    assert response.json()["full_name"] == "Updated Name"
    assert client.get("/profile", headers=headers).json()["farm_name"] == "Pond Farm"
    assert "password_hash" not in response.json()
    with Session(engine) as session:
        assert session.get(User, 2).full_name == "second"
        assert session.get(FarmerProfile, 2) is None
    assert client.put("/profile", headers=headers, json={**data, "user_id": 2}).status_code == 422
    assert client.put("/profile", headers=headers, json={**data, "email": "other@example.com"}).status_code == 422
    assert client.put("/profile", headers=headers, json={**data, "full_name": "  "}).status_code == 422
    assert client.put("/profile", headers=headers, json={**data, "farm_name": "x" * 161}).status_code == 422
    assert client.put("/profile", headers=headers, json={"full_name": "Updated Name"}).json()["farm_name"] == ""


def test_password_requires_current_and_stores_hash(setup):
    client, engine, headers = setup
    assert client.post("/profile/password", headers=headers, json={
        "current_password": "wrong", "new_password": "new-password",
    }).status_code == 400
    assert client.post("/profile/password", headers=headers, json={
        "current_password": "old-password", "new_password": "short",
    }).status_code == 422
    assert client.post("/profile/password", headers=headers, json={
        "current_password": "old-password", "new_password": "old-password",
    }).status_code == 422
    assert client.post("/profile/password", headers=headers, json={
        "current_password": "old-password", "new_password": "new-password",
    }).status_code == 200
    with Session(engine) as session:
        stored = session.get(User, 1).password_hash
        assert stored != "new-password"
        assert auth.password_hasher.verify("new-password", stored)
        assert not auth.password_hasher.verify("old-password", stored)
        assert auth.password_hasher.verify("old-password", session.get(User, 2).password_hash)
