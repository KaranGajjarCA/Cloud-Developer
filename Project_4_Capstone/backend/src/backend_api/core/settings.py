# -*- coding: utf-8 -*-
from __future__ import absolute_import
import logging
import os

from pydantic import BaseSettings

log = logging.getLogger(__name__)


class Settings(BaseSettings):
    todo_table: str = os.environ.get("DYNAMODB_HISTORY_TABLE", "todo_table")


def get_settings() -> Settings:
    settings = Settings()
    log.debug(f"Loading settings {settings}")
    return settings
