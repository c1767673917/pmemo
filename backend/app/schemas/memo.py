from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class TagBase(BaseModel):
    name: str
    color: Optional[str] = "#1abc9c"


class TagCreate(TagBase):
    pass


class Tag(TagBase):
    id: int
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True


class MemoBase(BaseModel):
    title: str
    content: str
    is_public: Optional[bool] = False


class MemoCreate(MemoBase):
    tags: Optional[List[int]] = []


class MemoUpdate(MemoBase):
    title: Optional[str] = None
    content: Optional[str] = None
    tags: Optional[List[int]] = None


class Memo(MemoBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    tags: List[Tag] = []

    class Config:
        from_attributes = True 