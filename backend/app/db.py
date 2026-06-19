"""Lapisan penyimpanan — mendukung **SQLite** (default) dan **PostgreSQL**.

Pilihan engine ditentukan oleh environment `DATABASE_URL`:
  - kosong / tidak diset            → SQLite (file `LMS_DB_PATH`)
  - `postgresql://user:pass@host/db`→ PostgreSQL (psycopg + connection pool)

Pola penyimpanan *document store*: tiap entitas = pasangan (collection, id)
dengan payload JSON. Selaras dengan `toMap()` / `fromMap(id, map)` di model
Flutter sehingga backend tidak perlu menduplikasi setiap field. Modul ini
sengaja diisolasi: migrasi SQLite → PostgreSQL cukup mengubah `DATABASE_URL`.
"""
import json
import threading
from contextlib import contextmanager
from datetime import datetime, timezone
from typing import Any, Iterator, Optional

from . import config

_PG = bool(config.DATABASE_URL) and config.DATABASE_URL.startswith(
    ("postgres://", "postgresql://")
)

# ── Engine-specific setup ───────────────────────────────────────────────────
if _PG:
    import psycopg
    from psycopg.rows import dict_row
    from psycopg.types.json import Jsonb
    from psycopg_pool import ConnectionPool

    _PLACEHOLDER = "%s"
    _JSON_TYPE = "JSONB"
    _pool = ConnectionPool(
        config.DATABASE_URL,
        min_size=1,
        max_size=10,
        open=False,
        kwargs={"row_factory": dict_row, "autocommit": True},
    )

    @contextmanager
    def _cursor() -> Iterator[Any]:
        with _pool.connection() as conn:
            with conn.cursor() as cur:
                yield cur

    def _dump(payload: dict[str, Any]) -> Any:
        return Jsonb(payload)

    def _load(value: Any) -> dict[str, Any]:
        return value if isinstance(value, dict) else json.loads(value)

    def _open_engine() -> None:
        _pool.open()

else:
    import sqlite3

    _PLACEHOLDER = "?"
    _JSON_TYPE = "TEXT"
    _lock = threading.Lock()

    def _connect() -> "sqlite3.Connection":
        conn = sqlite3.connect(config.DB_PATH, check_same_thread=False)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA journal_mode=WAL;")
        return conn

    _conn = _connect()

    @contextmanager
    def _cursor() -> Iterator[Any]:
        with _lock:
            cur = _conn.cursor()
            try:
                yield cur
                _conn.commit()
            finally:
                cur.close()

    def _dump(payload: dict[str, Any]) -> Any:
        return json.dumps(payload)

    def _load(value: Any) -> dict[str, Any]:
        return json.loads(value) if isinstance(value, str) else value

    def _open_engine() -> None:
        pass


P = _PLACEHOLDER


def engine_name() -> str:
    return "postgresql" if _PG else "sqlite"


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


# ── Skema ───────────────────────────────────────────────────────────────────

def init_db() -> None:
    _open_engine()
    with _cursor() as cur:
        cur.execute(
            f"""
            CREATE TABLE IF NOT EXISTS documents (
                collection TEXT NOT NULL,
                id         TEXT NOT NULL,
                data       {_JSON_TYPE} NOT NULL,
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
        cur.execute(
            f"SELECT id, data FROM documents WHERE collection = {P} ORDER BY updated_at",
            (collection,),
        )
        rows = cur.fetchall()
    out = []
    for row in rows:
        item = _load(row["data"])
        item["id"] = row["id"]
        out.append(item)
    return out


def get_document(collection: str, doc_id: str) -> Optional[dict[str, Any]]:
    with _cursor() as cur:
        cur.execute(
            f"SELECT id, data FROM documents WHERE collection = {P} AND id = {P}",
            (collection, doc_id),
        )
        row = cur.fetchone()
    if row is None:
        return None
    item = _load(row["data"])
    item["id"] = row["id"]
    return item


def upsert_document(collection: str, doc_id: str, data: dict[str, Any]) -> dict[str, Any]:
    payload = {k: v for k, v in data.items() if k != "id"}
    with _cursor() as cur:
        cur.execute(
            f"""
            INSERT INTO documents (collection, id, data, updated_at)
            VALUES ({P}, {P}, {P}, {P})
            ON CONFLICT (collection, id) DO UPDATE SET data = excluded.data,
                                                       updated_at = excluded.updated_at
            """,
            (collection, doc_id, _dump(payload), _now()),
        )
    result = dict(payload)
    result["id"] = doc_id
    return result


def delete_document(collection: str, doc_id: str) -> None:
    with _cursor() as cur:
        cur.execute(
            f"DELETE FROM documents WHERE collection = {P} AND id = {P}",
            (collection, doc_id),
        )


def count_documents(collection: str) -> int:
    with _cursor() as cur:
        cur.execute(
            f"SELECT COUNT(*) AS n FROM documents WHERE collection = {P}",
            (collection,),
        )
        row = cur.fetchone()
    return int(row["n"])


# ── Credentials ─────────────────────────────────────────────────────────────

def set_credential(email: str, password_hash: str, user_id: str) -> None:
    with _cursor() as cur:
        cur.execute(
            f"""
            INSERT INTO credentials (email, password_hash, user_id)
            VALUES ({P}, {P}, {P})
            ON CONFLICT (email) DO UPDATE SET password_hash = excluded.password_hash,
                                             user_id = excluded.user_id
            """,
            (email.lower(), password_hash, user_id),
        )


def get_credential(email: str) -> Optional[dict[str, Any]]:
    with _cursor() as cur:
        cur.execute(
            f"SELECT email, password_hash, user_id FROM credentials WHERE email = {P}",
            (email.lower(),),
        )
        return cur.fetchone()


def credential_exists(email: str) -> bool:
    return get_credential(email) is not None
