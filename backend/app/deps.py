"""Dependency FastAPI: ekstraksi pengguna aktif dari header Authorization."""
from typing import Any

import jwt
from fastapi import Depends, Header, HTTPException, status

from . import db, security


def get_current_user(authorization: str = Header(default="")) -> dict[str, Any]:
    if not authorization.lower().startswith("bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token tidak ditemukan",
        )
    token = authorization.split(" ", 1)[1].strip()
    try:
        user_id = security.decode_token(token)
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token tidak valid atau kedaluwarsa",
        )
    user = db.get_document("users", user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Pengguna tidak ditemukan",
        )
    return user


CurrentUser = Depends(get_current_user)
