# server/app/routers/goals.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from .. import crud, schemas, auth
from ..database import get_db

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