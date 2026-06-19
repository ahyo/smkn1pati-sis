"""Aplikasi FastAPI — backend Sistem Informasi SMK Negeri 1 Pati.

Menggantikan rencana awal berbasis Firebase. Menyediakan autentikasi JWT dan
CRUD untuk seluruh koleksi data yang dipakai aplikasi Flutter.
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import config, db, seed
from .routers import auth, collections

app = FastAPI(
    title="SMK Negeri 1 Pati — API",
    description="Backend FastAPI untuk Sistem Informasi & Pembelajaran Digital SMK Negeri 1 Pati.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=config.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def _startup() -> None:
    db.init_db()
    seed.seed_if_empty()


@app.get("/", tags=["meta"])
def root() -> dict[str, str]:
    return {
        "app": "SMK Negeri 1 Pati API",
        "status": "ok",
        "docs": "/docs",
    }


@app.get("/api/health", tags=["meta"])
def health() -> dict[str, str]:
    return {"status": "ok"}


app.include_router(auth.router)
app.include_router(collections.router)
