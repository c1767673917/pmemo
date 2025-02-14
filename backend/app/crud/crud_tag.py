from typing import List, Optional
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.memo import Tag
from app.schemas.memo import TagCreate, TagUpdate


class CRUDTag(CRUDBase[Tag, TagCreate, TagUpdate]):
    def create_with_user(
        self, db: Session, *, obj_in: TagCreate, user_id: int
    ) -> Tag:
        db_obj = Tag(
            name=obj_in.name,
            color=obj_in.color,
            user_id=user_id,
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_multi_by_user(
        self, db: Session, *, user_id: int, skip: int = 0, limit: int = 100
    ) -> List[Tag]:
        return (
            db.query(self.model)
            .filter(Tag.user_id == user_id)
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_by_name(
        self, db: Session, *, name: str, user_id: int
    ) -> Optional[Tag]:
        return (
            db.query(self.model)
            .filter(Tag.name == name, Tag.user_id == user_id)
            .first()
        )


tag = CRUDTag(Tag) 