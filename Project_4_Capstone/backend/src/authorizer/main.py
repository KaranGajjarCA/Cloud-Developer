import jwt


def generate_policy(effect, resource, context=None):
    auth_response = {"principalId": "user"}

    if effect and resource:
        policy_document = {
            "Version": "2012-10-17",
            "Statement": [{"Action": "execute-api:Invoke", "Effect": effect, "Resource": resource}],
        }
        auth_response["policyDocument"] = policy_document
        if context:
            auth_response["context"] = context
    return auth_response


def verify_token(access_token):
    try:
        jwks_url = "https://dev-kefaaohazhomyz2b.us.auth0.com/.well-known/jwks.json"

        if not access_token:
            return False
        if not str(access_token).lower().startswith('bearer'):
            return False
        token = access_token.split(' ')[1]

        jwks_client = jwt.PyJWKClient(jwks_url)
        signing_key = jwks_client.get_signing_key_from_jwt(token)

        decoded_payload = jwt.decode(token, signing_key.key, algorithms=["RS256"],
                                     audience="https://dev-kefaaohazhomyz2b.us.auth0.com/api/v2/",
                                     options={"require": ["exp", "iss", "sub"]})
        return decoded_payload
    except Exception:
        return {}
    return {}


def handler(event, context):
    access_token = event.get("authorizationToken")
    jwt_token_valid = verify_token(access_token)
    print("jwt_token_valid==",jwt_token_valid)
    if jwt_token_valid:
        return generate_policy(
            "Allow", event.get("methodArn"),
            {"platform_id": jwt_token_valid.get('sub')}
        )
    else:
        return generate_policy("Deny", "*")
