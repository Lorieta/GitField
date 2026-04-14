from fastapi import FastAPI
from routes.git_routes import git_router
app = FastAPI()
app.include_router(git_router)

@app.get("/")
async def root():
    return {"message": "Hello World"}