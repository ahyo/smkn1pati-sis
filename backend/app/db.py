"""Lapisan penyimpanan berbasis SQLite.

Menggunakan pola *document store*: setiap entitas disimpan sebagai pasangan
(collection, id) dengan payload JSON. Ini selaras dengan model Flutter yang
sudah memakai pola `toMap()` / `fromMap(id, map)`, sehingga backend tidak perlu
menduplikasi setiap field model.
"""
import json
import sqlite3
import threading
from contextlib import contextmanager
from typing import Any, Iterator, Optional

from . import config

_lock = threading.Lock()


def _connect() -> sqlite3.Connection:
    conn = sqlite3.connect(config.DB_PATH, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL;")
    return conn


_conn = _connect()


@contextmanager
def _cursor() -> Iterator[sqlite3.Cursor]:
    with _lock:
        cur = _conn.cursor()
        try:
            yield cur
            _conn.commit()
        finally:
            cur.close()


def init_db() -> None:
    with _cursor() as cur:
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS documents (
                collection TEXT NOT NULL,
                id         TEXT NOT NULL,
                data       TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                PRIMARY KEY (collection, id)
            )
            """
        )
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS credentials (
                email         TEXT PRIMARY KEY,
                password_hash TEXT NOT NULL,
                user_id       TEXT NOT NULL
            )
            """
        )


# ── Document store ──────────────────────────────────────────────────────────

def list_documents(collection: str) -> list[dict[str, Any]]:
    with _cursor() as cur:
        rows = cur.execute(
            "SELECT id, data FROM documents WHERE collection = ? ORDER BY updated_at",
            (collection,),
        ).fetchall()
    out = []
    for row in rows:
        item = json.loads(row["data"])
        item["id"] = row["id"]
        out.append(item)
    return out


def get_document(collection: str, doc_id: str) -> Optional[dict[str, Any]]:
    with _cursor() as cur:
        row = cur.execute(
            "SELECT id, data FROM documents WHERE collection = ? AND id = ?",
            (collection, doc_id),
        ).fetchone()
    if row is None:
        return None
    item = json.loads(row["data"])
    item["id"] = row["id"]
    return item


def upsert_document(collection: str, doc_id: str, data: dict[str, Any]) -> dict[str, Any]:
    import datetime

    payload = {k: v for k, v in data.items() if k != "id"}
    now = datetime.datetime.utcnow().isoformat()
    with _cursor() as cur:
        cur.execute(
            """
            INSERT INTO documents (collection, id, data, updated_at)
            VALUES (?, ?, ?, ?)
            ON CONFLICT(collection, id) DO UPDATE SET data = excluded.data,
                                                       updated_at = excluded.updated_at
            """,
            (collection, doc_id, json.dumps(payload), now),
        )
    result = dict(payload)
    result["id"] = doc_id
    return result


def delete_document(collection: str, doc_id: str) -> None:
    with _cursor() as cur:
        cur.execute(
            "DELETE FROM documents WHERE collection = ? AND id = ?",
            (collection, doc_id),
        )


def count_documents(collection: str) -> int:
    with _cursor() as cur:
        row = cur.execute(
            "SELECT COUNT(*) AS n FROM documents WHERE collection = ?",
            (collection,),
        ).fetchone()
    return int(row["n"])


# ── Credentials ─────────────────────────────────────────────────────────────

def set_credential(email: str, password_hash: str, user_id: str) -> None:
    with _cursor() as cur:
        cur.execute(
            """
            INSERT INTO credentials (email, password_hash, user_id)
            VALUES (?, ?, ?)
            ON CONFLICT(email) DO UPDATE SET password_hash = excluded.password_hash,
                                             user_id = excluded.user_id
            """,
            (email.lower(), password_hash, user_id),
        )


def get_credential(email: str) -> Optional[sqlite3.Row]:
    with _cursor() as cur:
        return cur.execute(
            "SELECT email, password_hash, user_id FROM credentials WHERE email = ?",
            (email.lower(),),
        ).fetchone()


def credential_exists(email: str) -> bool:
    return get_credential(email) is not None
