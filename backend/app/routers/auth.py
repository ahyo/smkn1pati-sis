"""Endpoint autentikasi: register, login, profil, ganti kata sandi.

Selaras dengan kontrak `AuthService` di aplikasi Flutter.
"""
from typing import Any

from fastapi import APIRouter, HTTPException, status

from .. import db, security
from ..deps import CurrentUser
from ..schemas import (
    AuthResponse,
    ChangePasswordRequest,
    LoginRequest,
    ProfileUpdateRequest,
    RegisterRequest,
)

router = APIRouter(prefix="/api/auth", tags=["auth"])


def _with_id(doc: dict[str, Any], doc_id: str) -> dict[str, Any]:
    out = dict(doc)
    out["id"] = doc_id
    return out


@router.post("/register", response_model=AuthResponse)
def register(req: RegisterRequest) -> AuthResponse:
    email = req.email.strip().lower()
    if db.credential_exists(email):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email sudah terdaftar")
    profile = dict(req.profile)
    profile["email"] = email
    profile["name"] = req.name
    user = db.upsert_document("users", req.id, profile)
    db.set_credential(email, security.hash_password(req.password), req.id)
    return AuthResponse(token=security.create_token(req.id), user=user)


@router.post("/login", response_model=AuthResponse)
def login(req: LoginRequest) -> AuthResponse:
    email = req.email.strip().lower()
    cred = db.get_credential(email)
    if cred is None or not security.verify_password(req.password, cred["password_hash"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email atau kata sandi salah",
        )
    user = db.get_document("users", cred["user_id"])
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Pengguna tidak ditemukan",
        )
    return AuthResponse(token=security.create_token(cred["user_id"]), user=user)


@router.get("/me")
def me(user: dict[str, Any] = CurrentUser) -> dict[str, Any]:
    return user


@router.put("/profile")
def update_profile(req: ProfileUpdateRequest, user: dict[str, Any] = CurrentUser) -> dict[str, Any]:
    if req.id != user["id"]:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Tidak diizinkan")
    profile = dict(req.profile)
    # Email tidak boleh berubah lewat endpoint ini.
    profile["email"] = user.get("email")
    return db.upsert_document("users", req.id, profile)


@router.post("/change-password", status_code=status.HTTP_204_NO_CONTENT)
def change_password(req: ChangePasswordRequest, user: dict[str, Any] = CurrentUser) -> None:
    email = (user.get("email") or "").lower()
    cred = db.get_credential(email)
    if cred is None or not security.verify_password(req.currentPassword, cred["password_hash"]):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Kata sandi saat ini salah",
        )
    if len(req.newPassword) < 6:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Kata sandi baru minimal 6 karakter",
        )
    db.set_credential(email, security.hash_password(req.newPassword), user["id"])
