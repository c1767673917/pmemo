from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps

router = APIRouter()


@router.get("/", response_model=List[schemas.Memo])
def read_memos(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Retrieve memos.
    """
    memos = crud.memo.get_multi_by_user(
        db=db, user_id=current_user.id, skip=skip, limit=limit
    )
    return memos


@router.post("/", response_model=schemas.Memo)
def create_memo(
    *,
    db: Session = Depends(deps.get_db),
    memo_in: schemas.MemoCreate,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Create new memo.
    """
    memo = crud.memo.create_with_user(db=db, obj_in=memo_in, user_id=current_user.id)
    return memo


@router.get("/{id}", response_model=schemas.Memo)
def read_memo(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Get memo by ID.
    """
    memo = crud.memo.get(db=db, id=id)
    if not memo:
        raise HTTPException(status_code=404, detail="Memo not found")
    if not memo.is_public and (memo.user_id != current_user.id):
        raise HTTPException(status_code=400, detail="Not enough permissions")
    return memo


@router.put("/{id}", response_model=schemas.Memo)
def update_memo(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    memo_in: schemas.MemoUpdate,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Update memo.
    """
    memo = crud.memo.get(db=db, id=id)
    if not memo:
        raise HTTPException(status_code=404, detail="Memo not found")
    if memo.user_id != current_user.id:
        raise HTTPException(status_code=400, detail="Not enough permissions")
    memo = crud.memo.update(db=db, db_obj=memo, obj_in=memo_in)
    return memo


@router.delete("/{id}", response_model=schemas.Memo)
def delete_memo(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Delete memo.
    """
    memo = crud.memo.get(db=db, id=id)
    if not memo:
        raise HTTPException(status_code=404, detail="Memo not found")
    if memo.user_id != current_user.id:
        raise HTTPException(status_code=400, detail="Not enough permissions")
    memo = crud.memo.remove(db=db, id=id)
    return memo


@router.get("/search/", response_model=List[schemas.Memo])
def search_memos(
    *,
    db: Session = Depends(deps.get_db),
    q: str = Query(None, min_length=3),
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Search memos by title or content.
    """
    memos = crud.memo.search(db=db, user_id=current_user.id, query=q)
    return memos 