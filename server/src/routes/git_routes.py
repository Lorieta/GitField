from fastapi import APIRouter
from models import UserBase
import requests

git_router = APIRouter()

#Retrieve Number of plot per Repo
@git_router.get("/repo_commit")
async def get_repo_commits(user, repo):
    response = requests.get(f"https://api.github.com/repos/{user}/{repo}/stats/participation")
    total_commits = response.json()
    total_plots = sum(list(map(int, total_commits['owner'])))
    return total_plots

