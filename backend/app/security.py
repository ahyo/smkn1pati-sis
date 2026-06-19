"""Hashing kata sandi (PBKDF2, stdlib) dan token JWT (PyJWT)."""
import datetime
import hashlib
import hmac
import os

import jwt

from . import config

_ITERATIONS = 120_000


def hash_password(password: str) -> str:
    salt = os.urandom(16)
    dk = hashlib.pbkdf2_hmac("sha256", password.encode(), salt, _ITERATIONS)
    return f"{salt.hex()}${dk.hex()}"


def verify_password(password: str, stored: str) -> bool:
    try:
        salt_hex, hash_hex = stored.split("$", 1)
    except ValueError:
        return False
    dk = hashlib.pbkdf2_hmac("sha256", password.encode(), bytes.fromhex(salt_hex), _ITERATIONS)
    return hmac.compare_digest(dk.hex(), hash_hex)


def create_token(user_id: str) -> str:
    now = datetime.datetime.now(datetime.timezone.utc)
    payload = {
        "sub": user_id,
        "iat": now,
        "exp": now + datetime.timedelta(hours=config.TOKEN_TTL_HOURS),
    }
    return jwt.encode(payload, config.SECRET_KEY, algorithm="HS256")


def decode_token(token: str) -> str:
    """Mengembalikan user_id (sub) dari token, atau memicu jwt error."""
    data = jwt.decode(token, config.SECRET_KEY, algorithms=["HS256"])
    return data["sub"]
