# server/app/routers/goals.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from .. import crud, schemas, auth, models, coaching_engine
from ..database import get_db
import uuid
from datetime import date

router = APIRouter(
    prefix="/goals",
    tags=["Goals"],
    dependencies=[Depends(auth.get_current_user)] # All endpoints in this router require login
)

@router.post("/", response_model=schemas.Goal, status_code=201)
def create_goal(
    goal: schemas.GoalCreate,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(auth.get_current_user)
):
    return crud.create_user_goal(db=db, goal=goal, user_id=current_user.user_id)


@router.get("/", response_model=List[schemas.Goal])
def read_goals(
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(auth.get_current_user)
):
    goals = crud.get_goals_by_user(db=db, user_id=current_user.user_id)
    return goals
    

# the new "smart" endpoint
@router.post("/{goal_id}/generate-plan", response_model=schemas.WeeklyPlan)
def get_goal_plan(
    goal_id: uuid.UUID,
    current_user: schemas.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    # verify the goal exists and belongs to the user
    goal = db.query(models.Goal).filter(
        models.Goal.goal_id == goal_id,
        models.Goal.user_id == current_user.user_id
    ).first()

    if not goal:
        raise HTTPException(status_code=404, detail="Goal not found")

    # Basic logic to determine the current week.
    # It calculates how many weeks have passed since the goal was created.
    weeks_passed = (date.today() - goal.created_at.date()).days // 7
    current_week = weeks_passed + 1
    
    # Check if the goal is a running goal before generating a plan
    if "run" not in goal.title.lower() and "5k" not in goal.title.lower():
        raise HTTPException(status_code=400, detail="Plan generation is only available for running goals currently.")

    # Call our coaching engine!
    plan = coaching_engine.generate_running_plan(current_week=current_week)
    
    if not plan:
         raise HTTPException(status_code=404, detail="No plan available for the current week.")

    return plan