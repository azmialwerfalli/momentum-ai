# server/app/routers/progress.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import date
import uuid

from .. import crud, schemas, auth, models, coaching_engine 
from ..database import get_db

router = APIRouter(
    tags=["Progress & Dashboard"],
    dependencies=[Depends(auth.get_current_user)] # Secure all endpoints
)

@router.post("/progress-logs", response_model=schemas.ProgressLog, status_code=201)
def create_progress_log(
    log: schemas.ProgressLogCreate,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(auth.get_current_user)
):
    # Security check: ensure the habit belongs to the current user
    habit = db.query(models.Habit).filter(
        models.Habit.habit_id == log.habit_id,
        models.Habit.user_id == current_user.user_id
    ).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found or you do not own this habit")

    return crud.log_progress_for_habit(db=db, log=log, user_id=current_user.user_id)

@router.get("/dashboard/{target_date}", response_model=List[schemas.DashboardHabit])
def get_dashboard(
    target_date: date,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(auth.get_current_user)
):
    return crud.get_dashboard_for_date(db=db, user_id=current_user.user_id, target_date=target_date)

    
@router.post("/feedback/missed-habit", response_model=dict)
def get_missed_habit_feedback(
    request: schemas.MissedHabitFeedbackRequest, # Use the new request model
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(auth.get_current_user)
):
    # Find the habit in the DB to get its title
    habit = db.query(models.Habit).filter(
        models.Habit.habit_id == request.habit_id,
        models.Habit.user_id == current_user.user_id
    ).first()


    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")

    # Call the new, smarter coaching engine function
    advice = coaching_engine.get_missed_habit_feedback(
        habit_title=habit.title, 
        reason=request.reason
    )

    return {"feedback": advice}