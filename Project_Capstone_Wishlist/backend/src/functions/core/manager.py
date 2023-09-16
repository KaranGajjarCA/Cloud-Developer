from datetime import datetime
import jwt
import boto3
from boto3.dynamodb.conditions import Key, Attr
from ..core.settings import get_settings

settings = get_settings()
table_name = settings.wishlist_table
bucket_name = settings.wishlist_bucket
table = boto3.resource("dynamodb").Table(table_name)


def parse_token_user_id(token):
    jwks_url = "https://dev-kefaaohazhomyz2b.us.auth0.com/.well-known/jwks.json"

    if not token:
        return False
    if not str(token).lower().startswith('bearer'):
        return False
    token = token.split(' ')[1]

    jwks_client = jwt.PyJWKClient(jwks_url)
    signing_key = jwks_client.get_signing_key_from_jwt(token)

    decoded_payload = jwt.decode(token, signing_key.key, algorithms=["RS256"],
                                 audience=["hiCFWgg4Lv8KEBcK78r4FA5JgIdbCXuZ",
                                           "https://dev-kefaaohazhomyz2b.us.auth0.com/api/v2/"],
                                 options={"require": ["exp", "iss", "sub"]})
    return decoded_payload.get("sub")


def get_all_wishlist_items(user_id, wishlist_id=None):
    if wishlist_id:
        wishlist = table.query(
            KeyConditionExpression=Key("user_id").eq(user_id) & Key("wishlist_id").eq(wishlist_id),
        )
    else:
        wishlist = table.query(
            KeyConditionExpression=Key("user_id").eq(user_id),
        )
    return wishlist.get("Items", [])


def create_wishlist_item(user_id, payload):
    wishlist_id = str(datetime.now().strftime("%Y%m%d%H%M%S%f"))
    new_item = {
        "user_id": user_id,
        "wishlist_id": wishlist_id,
        "created_date": str(datetime.now().date()),
        "name": payload.get("name"),
        "description": payload.get("description"),
        "category": payload.get("category"),
        "price": payload.get("price"),
        "completed": False,
        "attachment_url": wishlist_id
    }
    table.put_item(Item=new_item)
    return get_all_wishlist_items(user_id)


def update_wishlist_item(user_id, payload):
    update_expression = "SET description = :description, category = :category, price = :price, completed = :completed"
    expression_attributes = {
        ":description": payload.get("description"),
        ":category": payload.get("category"),
        ":price": payload.get("price"),
        ":completed": payload.get("completed"),
    }
    table.update_item(
        Key={"user_id": user_id, "wishlist_id": payload.get("wishlist_id")},
        ConditionExpression=Attr("user_id").exists() & Attr("wishlist_id").exists(),
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_attributes,
        ReturnValues="ALL_NEW",
    )
    return get_all_wishlist_items(user_id)


def delete_wishlist(payload):
    table.delete_item(Key={"user_id": payload.get("user_id"), "wishlist_id": payload.get("wishlist_id")})
    return get_all_wishlist_items(payload.get("user_id"))


def get_image_upload_url(payload):
    s3 = boto3.client('s3', region_name='us-east-1')
    wishlist = get_all_wishlist_items(user_id=payload.get("user_id"), wishlist_id=payload.get("wishlist_id"))
    if not wishlist:
        return False

    signed_url = s3.generate_presigned_url(
        'put_object',
        Params={'Bucket': bucket_name, 'Key': payload.get("wishlist_id")},
        ExpiresIn=3600
    )

    download_signed_url = s3.generate_presigned_url(
        'get_object',
        Params={'Bucket': bucket_name, 'Key': payload.get("wishlist_id")},
    )

    update_expression = "SET attachment_url = :attachment_url"
    expression_attributes = {
        ":attachment_url": download_signed_url
    }
    table.update_item(
        Key={"user_id": payload.get("user_id"), "wishlist_id": payload.get("wishlist_id")},
        ConditionExpression=Attr("user_id").exists() & Attr("wishlist_id").exists(),
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_attributes,
        ReturnValues="ALL_NEW",
    )
    return signed_url

