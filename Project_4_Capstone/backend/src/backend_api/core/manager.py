from datetime import datetime

import boto3
from boto3.dynamodb.conditions import Key, Attr
from ..core.settings import get_settings

settings = get_settings()
table_name = settings.todo_table
table = boto3.resource("dynamodb").Table(table_name)


def get_todos(platform_id):
    todo_list = table.query(
        KeyConditionExpression=Key("user_id").eq(platform_id),
    )
    return todo_list.get("Items", [])


def create_todos(platform_id, payload):
    new_item = {
        "user_id": platform_id,
        "todo_id": str(datetime.now().strftime("%Y%m%d%H%M%S%f")),
        "todo_text": payload.get("todo_text"),
        "created_datetime": str(datetime.utcnow()),
        "done": False
    }
    table.put_item(Item=new_item)
    return get_todos(platform_id)


def update_todos(platform_id, payload):
    update_expression = "SET todo_text = :todo_text, done = :done"
    expression_attributes = {
        ":todo_text": payload.get("todo_text"),
        ":done": payload.get("done")
    }
    table.update_item(
        Key={"user_id": platform_id, "todo_id": payload.get("todo_id")},
        ConditionExpression=Attr("user_id").exists() & Attr("todo_id").exists(),
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_attributes,
        ReturnValues="ALL_NEW",
    )
    return get_todos(platform_id)


def delete_todos(payload):
    table.delete_item(Key={"user_id": payload.get("platform_id"), "todo_id": payload.get("todo_id")})
    return get_todos(payload.get("platform_id"))

