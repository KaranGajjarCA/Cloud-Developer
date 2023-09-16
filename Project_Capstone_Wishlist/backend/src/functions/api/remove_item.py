from fastapi import Depends, FastAPI, HTTPException, Request, Response
from mangum import Mangum
from ..core import manager
from botocore.exceptions import ClientError
import logging


log = logging.getLogger(__name__)
app = FastAPI()


@app.post("/wishlist/{wishlist_id}/remove")
async def remove_iteam(request: Request, wishlist_id: str):
    try:
        token = request.headers.get("authorization")
        user_id = manager.parse_token_user_id(token)
        payload = {
            "user_id": user_id,
            "wishlist_id": wishlist_id
        }
        return {"items": manager.delete_wishlist(payload)}
    except ClientError as e:
        log.error(f"Error occurs during delete wishlist {str(e)}")
        return {
            "status": 400,
            "Error": str(e)
        }
    except Exception as e:
        log.error(f"Error occurs during delete wishlist {str(e)}")
        return {"status": 500, "error": str(e)}


handler = Mangum(app=app)
