from pydantic_settings import BaseSettings
from typing import Optional
import secrets


class Settings(BaseSettings):
    PROJECT_NAME: str = "PMemo"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = secrets.token_urlsafe(32)
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8 days
    DATABASE_URL: str = "sqlite:///./data/pmemo.db"
    
    # CORS配置
    BACKEND_CORS_ORIGINS: list = ["http://localhost:3000"]
    
    # 超级管理员配置
    FIRST_SUPERUSER: str = "admin@example.com"
    FIRST_SUPERUSER_PASSWORD: str = "admin"
    
    class Config:
        case_sensitive = True
        env_file = ".env"


settings = Settings() 