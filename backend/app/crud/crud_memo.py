from typing import List, Optional
from sqlalchemy.orm import Session
from sqlalchemy import or_

from app.crud.base import CRUDBase
from app.models.memo import Memo
from app.schemas.memo import MemoCreate, MemoUpdate


class CRUDMemo(CRUDBase[Memo, MemoCreate, MemoUpdate]):
    def create_with_user(
        self, db: Session, *, obj_in: MemoCreate, user_id: int
    ) -> Memo:
        db_obj = Memo(
            title=obj_in.title,
            content=obj_in.content,
            is_public=obj_in.is_public,
            user_id=user_id,
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_multi_by_user(
        self, db: Session, *, user_id: int, skip: int = 0, limit: int = 100
    ) -> List[Memo]:
        return (
            db.query(self.model)
            .filter(Memo.user_id == user_id)
            .offset(skip)
            .limit(limit)
            .all()
        )

    def search(
        self, db: Session, *, user_id: int, query: str, skip: int = 0, limit: int = 100
    ) -> List[Memo]:
        return (
            db.query(self.model)
            .filter(
                Memo.user_id == user_id,
                or_(
                    Memo.title.ilike(f"%{query}%"),
                    Memo.content.ilike(f"%{query}%")
                )
            )
            .offset(skip)
            .limit(limit)
            .all()
        )


memo = CRUDMemo(Memo) 