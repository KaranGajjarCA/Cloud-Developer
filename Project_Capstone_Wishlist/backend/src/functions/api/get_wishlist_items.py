from fastapi import Depends, FastAPI, HTTPException, Request, Response
from mangum import Mangum
from ..core import manager
from botocore.exceptions import ClientError
import logging


log = logging.getLogger(__name__)

app = FastAPI()


@app.get("/wishlist/get")
async def get_wishlist_items(request: Request):
    try:
        token = request.headers.get("authorization")
        user_id = manager.parse_token_user_id(token)
        return {"items": manager.get_all_wishlist_items(user_id)}
    except ClientError as e:
        log.error(f"Error occurs during get wishlist {str(e)}")
        return {
            "status": 400,
            "Error": str(e)
        }
    except Exception as e:
        log.error(f"Error occurs during get wishlist {str(e)}")
        return {"status": 500, "error": str(e)}


handler = Mangum(app=app)
