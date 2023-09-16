from fastapi import FastAPI
from .routers import backend_api
from mangum import Mangum

app = FastAPI()

app.include_router(backend_api.router)

handler = Mangum(app=app)
