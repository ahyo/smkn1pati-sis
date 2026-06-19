"""Endpoint CRUD generik untuk seluruh koleksi data.

Memetakan langsung ke `DataService` Flutter:
  watch<Entity>()   -> GET    /api/{collection}
  upsert<Entity>()  -> PUT    /api/{collection}/{id}
  delete<Entity>()  -> DELETE /api/{collection}/{id}

Payload body adalah hasil `model.toMap()` (tanpa field `id`). Respons list
mengembalikan tiap dokumen lengkap dengan `id` agar bisa di-`fromMap(id, map)`.
"""
from typing import Any

from fastapi import APIRouter, Body, HTTPException, Path, status

from .. import config, db
from ..deps import CurrentUser

router = APIRouter(prefix="/api", tags=["data"])


def _validate(collection: str) -> None:
    if collection not in config.COLLECTIONS:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Koleksi '{collection}' tidak dikenal",
        )


@router.get("/{collection}")
def list_items(
    collection: str = Path(...),
    _: dict[str, Any] = CurrentUser,
) -> list[dict[str, Any]]:
    _validate(collection)
    return db.list_documents(collection)


@router.put("/{collection}/{item_id}")
def upsert_item(
    collection: str = Path(...),
    item_id: str = Path(...),
    body: dict[str, Any] = Body(default_factory=dict),
    _: dict[str, Any] = CurrentUser,
) -> dict[str, Any]:
    _validate(collection)
    return db.upsert_document(collection, item_id, body)


@router.delete("/{collection}/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(
    collection: str = Path(...),
    item_id: str = Path(...),
    _: dict[str, Any] = CurrentUser,
) -> None:
    _validate(collection)
    db.delete_document(collection, item_id)
