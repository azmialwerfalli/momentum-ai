# server/app/main.py

from fastapi import FastAPI
from . import models
from .database import engine
from .routers import auth

# This line tells SQLAlchemy to create the tables based on our models
# It checks if the tables exist first, so it's safe to run.
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Momentum AI API")


app.include_router(auth.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to the Momentum AI API! Database is connected."}