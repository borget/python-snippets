'''
    predictions lazzy load functionality for UI
'''
import json
import logging
from typing import Iterator, List, Optional, Tuple
from fastapi import WebSocket, Query, APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from starlette.websockets import WebSocketState
from app.constants.settings import Settings
from app.controllers.file.utils import read_gcs_file
from app.db.crud import get_prediction_by_id
from app.db.session import get_db
from app.security.auth0 import authenticate
router = APIRouter()

logger = logging.getLogger(Settings.API_NAME)
NEXT_ACTION = {"action": "next"}


async def authenticate_ws(
    websocket: WebSocket,
    token: Optional[str] = Query(None),
):
    response = None
    try:
        response = await authenticate(token=token)
    except Exception as exc:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
    return response


@router.websocket("/predictions/ws/{prediction_id}")
async def prediction_by_page(
        websocket: WebSocket,
        prediction_id: int,
        page_size: int = 50,
        token: str = Depends(authenticate_ws),
        db: Session = Depends(get_db)):
    prediction_name = None
    count = None
    predictions = None
    try:
        if websocket.application_state != WebSocketState.DISCONNECTED:
            prediction_name, prediction_gcs_path = get_prediction_by_id(prediction_id, db)
            data = read_gcs_file(prediction_gcs_path)
            data_json = json.loads(data).get("data")
            predictions = iter(data_json)
            count = len(data_json)
    except HTTPException:
        await websocket.close(code=status.WS_1000_NORMAL_CLOSURE)

    if websocket.application_state != WebSocketState.DISCONNECTED:
        await websocket.accept()
        await websocket.send_json({"prediction_id": prediction_id, "prediction_name": prediction_name, "row_count": count})

        while True:
            action = await websocket.receive_json()
            if action == NEXT_ACTION:
                is_exhausted, payload = _get_next_page(predictions, page_size)
                await websocket.send_json({"page": payload})
                if is_exhausted:
                    await websocket.close(code=status.WS_1000_NORMAL_CLOSURE)
                    break
            else:
                await websocket.send_json({"error": "wrong action"})


def _get_next_page(predictions: Iterator[dict], page_size: int) -> Tuple[bool, List[dict]]:
    is_exhausted = False
    data: List[dict] = []
    for _ in range(0, page_size):
        try:
            data.append(next(predictions))
        except StopIteration:
            is_exhausted = True
            return is_exhausted, data
    return is_exhausted, data
