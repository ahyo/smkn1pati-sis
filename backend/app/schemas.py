"""Skema request/response untuk endpoint autentikasi."""
from typing import Any, Optional

from pydantic import BaseModel, Field


class RegisterRequest(BaseModel):
    id: str = Field(..., description="ID pengguna yang dibuat klien (uuid)")
    email: str
    password: str
    name: str
    profile: dict[str, Any] = Field(default_factory=dict, description="AppUser.toMap()")


class LoginRequest(BaseModel):
    email: str
    password: str


class ProfileUpdateRequest(BaseModel):
    id: str
    profile: dict[str, Any]


class ChangePasswordRequest(BaseModel):
    currentPassword: str
    newPassword: str


class AuthResponse(BaseModel):
    token: str
    user: dict[str, Any]
