# server/app/schemas.py
from pydantic import BaseModel, EmailStr
import uuid
from datetime import date

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


    # --- Goal Schemas ---

class GoalBase(BaseModel):
    title: str
    description: str | None = None
    goal_type: str
    target_value: float | None = None
    target_unit: str | None = None
    target_date: date | None = None

class GoalCreate(GoalBase):
    pass # It has the same fields as GoalBase for now

class Goal(GoalBase):
    goal_id: uuid.UUID
    user_id: uuid.UUID
    status: str
    
    class Config:
        from_attributes = True

        # --- Habit Schemas ---

class HabitBase(BaseModel):
    title: str
    frequency_type: str | None = 'daily' # e.g., 'daily', 'weekly'
    frequency_value: int | None = 1 # e.g., 1 time a day, 3 times a week

class HabitCreate(HabitBase):
    goal_id: uuid.UUID # A habit must be linked to a goal

class Habit(HabitBase):
    habit_id: uuid.UUID
    goal_id: uuid.UUID
    user_id: uuid.UUID
    is_bad_habit: bool

    class Config:
        from_attributes = True

# --- Progress Log Schemas ---

class ProgressLogCreate(BaseModel):
    habit_id: uuid.UUID
    log_date: date
    value_achieved: float = 1 # Default to 1 for simple completion check

class ProgressLog(ProgressLogCreate):
    log_id: uuid.UUID
    user_id: uuid.UUID

    class Config:
        from_attributes = True


# --- Dashboard Schema ---

class DashboardHabit(BaseModel):
    habit_id: uuid.UUID
    title: str
    is_completed: bool