# server/app/config.py
from pydantic_settings import BaseSettings
from pathlib import Path

# This constructs an absolute path to the .env file in the parent directory of this file
env_path = Path(__file__).parent.parent / '.env'

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    algorithm: str
    access_token_expire_minutes: int

    class Config:
        env_file = env_path

settings = Settings()