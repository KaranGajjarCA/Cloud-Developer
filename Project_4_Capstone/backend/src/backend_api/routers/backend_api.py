from fastapi import Depends, FastAPI, HTTPException, Request, Response, APIRouter
from ..core.settings import get_settings
from ..core import manager
import jwt

router = APIRouter()

settings = get_settings()


def parse_token_platform_id(token):
    jwks_url = "https://dev-kefaaohazhomyz2b.us.auth0.com/.well-known/jwks.json"

    if not token:
        return False
    if not str(token).lower().startswith('bearer'):
        return False
    token = token.split(' ')[1]

    jwks_client = jwt.PyJWKClient(jwks_url)
    signing_key = jwks_client.get_signing_key_from_jwt(token)

    decoded_payload = jwt.decode(token, signing_key.key, algorithms=["RS256"],
                                 audience=["hiCFWgg4Lv8KEBcK78r4FA5JgIdbCXuZ","https://dev-kefaaohazhomyz2b.us.auth0.com/api/v2/"],
                                 options={"require": ["exp", "iss", "sub"]})
    return decoded_payload.get("sub")


@router.get("/todo/get_todo")
async def get_todo(request: Request):
    try:
        token = request.headers.get("authorization")
        platform_id = parse_token_platform_id(token)
        return {"todos": manager.get_todos(platform_id)}
    except Exception as e:
        print("Error: ", str(e))
        return {"status": 500, "error": str(e)}


@router.post("/todo/create")
async def process_todo(request: Request):
    payload = await request.json()
    try:
        token = request.headers.get("authorization")
        platform_id = parse_token_platform_id(token)
        return {"todos": manager.create_todos(platform_id, payload)}
    except Exception as e:
        print("Error: ", str(e))
        return {"status": 500, "error": str(e)}


@router.post("/todo/update")
async def update_todo(request: Request):
    payload = await request.json()
    try:
        token = request.headers.get("authorization")
        platform_id = parse_token_platform_id(token)
        return {"todos": manager.update_todos(platform_id, payload)}
    except Exception as e:
        print("Error: ", str(e))
        return {"status": 500, "error": str(e)}


@router.post("/todo/delete")
async def delete_todo(request: Request, todo_id: str):
    try:
        token = request.headers.get("authorization")
        platform_id = parse_token_platform_id(token)
        payload = {
            "platform_id": platform_id,
            "todo_id": todo_id
        }
        return {"todos": manager.delete_todos(payload)}
    except Exception as e:
        print("Error: ", str(e))
        return {"status": 500, "error": str(e)}
