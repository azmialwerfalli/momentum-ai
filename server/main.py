from fastapi import FastAPI

app = FastAPI(title="Momentum AI API")

@app.get("/")
def read_root():
    return {"message": "Welcome to the Momentum AI API!"}
