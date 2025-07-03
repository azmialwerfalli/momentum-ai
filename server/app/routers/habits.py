# server/app/routers/habits.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import uuid

from .. import crud, schemas, auth, models
from ..database import get_db

router = APIRouter(
    prefix="/habits",
    tags=["Habits"],
    dependencies=[Depends(auth.get_current_user)] # Secure all endpoints
)


@router.post("/", response_model=schemas.Habit, status_code=status.HTTP_201_CREATED)
def create_habit_for_goal(
    habit: schemas.HabitCreate,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(auth.get_current_user)
):
    # Optional: Verify the goal exists and belongs to the user before creating the habit
    goal = db.query(models.Goal).filter(
        models.Goal.goal_id == habit.goal_id,
        models.Goal.user_id == current_user.user_id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Goal not found or you do not own this goal")
    
    return crud.create_goal_habit(db=db, habit=habit, user_id=current_user.user_id)


@router.get("/by_goal/{goal_id}", response_model=List[schemas.Habit])
def read_habits_for_goal(
    goal_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(auth.get_current_user)
):
    habits = crud.get_habits_by_goal(db=db, goal_id=goal_id, user_id=current_user.user_id)
    return habits