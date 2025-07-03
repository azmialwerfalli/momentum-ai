# server/app/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from . import models
from .database import engine
from .routers import auth
from .routers import auth, goals, habits, progress 

# This line tells SQLAlchemy to create the tables based on our models
# It checks if the tables exist first, so it's safe to run.
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Momentum AI API")

#    For development, we can allow everything with "*"
origins = [
    "http://localhost",
    "http://localhost:8080",
    "http://127.0.0.1:8000",
    # Add the specific port your Flutter web app runs on if you know it, e.g., "http://localhost:54321"
    "*" # Using a wildcard is okay for development but should be more specific in production
]

# 3. Add the middleware to your app
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"], # Allow all methods (GET, POST, etc.)
    allow_headers=["*"], # Allow all headers
)
app.include_router(auth.router)
app.include_router(goals.router)
app.include_router(habits.router)
app.include_router(progress.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to the Momentum AI API! Database is connected."}