# server/app/crud.py
from sqlalchemy.orm import Session
from . import models, schemas
from passlib.context import CryptContext
import uuid
# Setup password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

def create_user(db: Session, user: schemas.UserCreate):
    hashed_password = pwd_context.hash(user.password)
    db_user = models.User(email=user.email, username=user.username, password_hash=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

    # --- Goal CRUD Functions ---

def create_user_goal(db: Session, goal: schemas.GoalCreate, user_id: uuid.UUID):
    db_goal = models.Goal(**goal.model_dump(), user_id=user_id)
    db.add(db_goal)
    db.commit()
    db.refresh(db_goal)
    return db_goal

def get_goals_by_user(db: Session, user_id: uuid.UUID):
    return db.query(models.Goal).filter(models.Goal.user_id == user_id).all()
    
# --- Habit CRUD Functions ---

def create_goal_habit(db: Session, habit: schemas.HabitCreate, user_id: uuid.UUID):
    db_habit = models.Habit(**habit.model_dump(), user_id=user_id)
    db.add(db_habit)
    db.commit()
    db.refresh(db_habit)
    return db_habit

def get_habits_by_goal(db: Session, goal_id: uuid.UUID, user_id: uuid.UUID):
    # We check both goal_id and user_id for security
    return db.query(models.Habit).filter(
        models.Habit.goal_id == goal_id,
        models.Habit.user_id == user_id
    ).all()