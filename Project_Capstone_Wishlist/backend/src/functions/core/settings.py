# -*- coding: utf-8 -*-
from __future__ import absolute_import
import logging
import os

from pydantic import BaseSettings

log = logging.getLogger(__name__)


class Settings(BaseSettings):
    wishlist_table: str = os.environ.get("DYNAMODB_TABLE_NAME", "wishlist_table")
    wishlist_bucket: str = os.environ.get("ATTACHMENT_S3_BUCKET", "wishlist-s3-bucket")


def get_settings() -> Settings:
    settings = Settings()
    log.debug(f"Loading settings {settings}")
    return settings
