# server/app/crud.py
from sqlalchemy.orm import Session, joinedload
from . import models, schemas
from passlib.context import CryptContext
from datetime import date
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
    # --- Progress Log and Dashboard CRUD Functions ---

def log_progress_for_habit(db: Session, log: schemas.ProgressLogCreate, user_id: uuid.UUID):
    # First, ensure this log doesn't already exist for this habit on this day
    existing_log = db.query(models.ProgressLog).filter(
        models.ProgressLog.habit_id == log.habit_id,
        models.ProgressLog.log_date == log.log_date,
        models.ProgressLog.user_id == user_id
    ).first()
    
    if existing_log:
        # You could choose to update it, or just return it. For now, we prevent duplicates.
        return existing_log

    db_log = models.ProgressLog(**log.model_dump(), user_id=user_id)
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return db_log

def get_dashboard_for_date(db: Session, user_id: uuid.UUID, target_date: date):
    # 1. Get all of the user's active habits
    user_habits = db.query(models.Habit).filter(models.Habit.user_id == user_id).all()

    # 2. Get all progress logs for that specific day
    logs_for_day = db.query(models.ProgressLog).filter(
        models.ProgressLog.user_id == user_id,
        models.ProgressLog.log_date == target_date
    ).all()
    
    # Create a set of completed habit IDs for fast lookup
    completed_habit_ids = {log.habit_id for log in logs_for_day}

    # 3. Build the dashboard response
    dashboard_data = []
    for habit in user_habits:
        dashboard_data.append(
            schemas.DashboardHabit(
                habit_id=habit.habit_id,
                title=habit.title,
                is_completed=(habit.habit_id in completed_habit_ids)
            )
        )
    return dashboard_data