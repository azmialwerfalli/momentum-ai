# server/app/schemas.py
from pydantic import BaseModel, EmailStr
import uuid

# Properties to receive via API on user creation
class UserCreate(BaseModel):
    email: EmailStr
    password: str
    username: str

# Properties to return to client
class User(BaseModel):
    user_id: uuid.UUID
    email: EmailStr
    username: str

    class Config:
        from_attributes = True # Replaces orm_mode = True

# Properties for receiving token data
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: EmailStr | None = None