import logging
from typing import List
import kfp
from fastapi import APIRouter
from fastapi import Depends
from fastapi.openapi.models import APIKey
from app.constants.settings import Settings
from app.endpoints.tags import PREDICTIONS
from app.schemas.run import Run
from app.security.auth0 import authenticate

router = APIRouter()
logger = logging.getLogger(Settings.API_NAME)


async def kubeflow_client() -> kfp.Client:
    return kfp.Client(host="https://4a09f1e63696b343-dot-us-central2.pipelines.googleusercontent.com/")


@router.get("/predictions/runs", tags=[PREDICTIONS], response_model=List[Run])
async def runs_by_client(client: kfp.Client = Depends(kubeflow_client), user_info: APIKey = Depends(authenticate)):
    """Run predictions as a component on Kubeflow"""
    # user_id = user_info.user_id
    user_id = "605a35a12bf888006fa24512"

    experiment = client.get_experiment(experiment_name=f"cube-experiment-{user_id}")
    run_list = client.list_runs(experiment_id=experiment.id, page_size=100)
    return [
        {"run_id": r.id,
         "name": r.name,
         "description": r.description,
         "status": r.status,
         "created_at": r.created_at,
         "finished_at": r.finished_at,
         "error": r.error}
        for r in run_list.runs
    ]
