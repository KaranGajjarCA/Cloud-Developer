from fastapi import Depends, FastAPI, HTTPException, Request, Response
from mangum import Mangum
from botocore.exceptions import ClientError
from ..core import manager
import logging


log = logging.getLogger(__name__)
app = FastAPI()


@app.post("/wishlist/update")
async def update_wishlist_item(request: Request):
    payload = await request.json()
    try:
        token = request.headers.get("authorization")
        user_id = manager.parse_token_user_id(token)
        return {"items": manager.update_wishlist_item(user_id, payload)}
    except ClientError as e:
        log.error(f"Error occurs during update wishlist {str(e)}")
        return {
            "status": 400,
            "Error": str(e)
        }
    except Exception as e:
        log.error(f"Error occurs during update wishlist {str(e)}")
        return {"status": 500, "error": str(e)}


handler = Mangum(app=app)
