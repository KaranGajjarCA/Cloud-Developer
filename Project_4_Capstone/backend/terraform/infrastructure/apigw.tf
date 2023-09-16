locals {
  gateway_log_format = {
    requestId               = "$context.requestId"
    sourceIp                = "$context.identity.sourceIp"
    requestTime             = "$context.requestTime"
    protocol                = "$context.protocol"
    httpMethod              = "$context.httpMethod"
    resourcePath            = "$context.resourcePath"
    routeKey                = "$context.routeKey"
    status                  = "$context.status"
    stage                   = "$context.stage"
    responseLength          = "$context.responseLength"
    integrationStatus       = "$context.integration.integrationStatus"
    integrationStatusCode   = "$context.integration.status"
    integrationErrorMessage = "$context.integrationErrorMessage"
    basePathMatched         = "$context.customDomain.basePathMatched"
    authError               = "$context.authenticate.error"
    responseLatency         = "$context.responseLatency"
    domainName              = "$context.domainName"
    domainPrefix            = "$context.domainPrefix"
  }
}


resource "aws_api_gateway_rest_api" "apigw" {
  name = var.apigw_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "apigw_lambda_authorizer" {
  name                             = "backend_api_authorizer"
  type                             = "TOKEN"
  rest_api_id                      = aws_api_gateway_rest_api.apigw.id
  identity_source                  = "method.request.header.Authorization"
  authorizer_uri                   = aws_lambda_function.backend_api_authorizer_lambda.invoke_arn
  authorizer_result_ttl_in_seconds = 0
}


resource "aws_lambda_permission" "apigw_lambda_permission" {
  depends_on = [
    aws_api_gateway_rest_api.apigw,
    aws_api_gateway_authorizer.apigw_lambda_authorizer
  ]

  function_name = "backend_api_authorizer"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  statement_id  = "AllowExecutionFromAPIGatewayAuthorizer"

  source_arn = "${aws_api_gateway_rest_api.apigw.execution_arn}/authorizers/${aws_api_gateway_authorizer.apigw_lambda_authorizer.id}"
}


resource "aws_api_gateway_resource" "apigw_resource_backend_api_parent" {
  parent_id   = aws_api_gateway_rest_api.apigw.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  path_part   = "todo"
}


# Todo:Get
resource "aws_api_gateway_resource" "apigw_resource_get_todo" {
  parent_id   = aws_api_gateway_resource.apigw_resource_backend_api_parent.id
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  path_part   = "get_todo"
}

resource "aws_api_gateway_method" "apigw_method_get_todo" {
  rest_api_id   = aws_api_gateway_rest_api.apigw.id
  resource_id   = aws_api_gateway_resource.apigw_resource_get_todo.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.apigw_lambda_authorizer.id
  request_parameters = {
    "method.request.header.Authorization" = true,
  }
  depends_on = [
    aws_api_gateway_authorizer.apigw_lambda_authorizer
  ]
}

resource "aws_api_gateway_method_response" "apigw_get_todo_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_get_todo.id
  http_method = aws_api_gateway_method.apigw_method_get_todo.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "apigw_get_todo_response_204" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_get_todo.id
  http_method = aws_api_gateway_method.apigw_method_get_todo.http_method
  status_code = "204"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "apigw_get_todo_response_401" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_get_todo.id
  http_method = aws_api_gateway_method.apigw_method_get_todo.http_method
  status_code = "401"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "apigw_get_todo_response_500" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_get_todo.id
  http_method = aws_api_gateway_method.apigw_method_get_todo.http_method
  status_code = "500"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "apigw_integration_get_history" {
  rest_api_id             = aws_api_gateway_rest_api.apigw.id
  resource_id             = aws_api_gateway_resource.apigw_resource_get_todo.id
  http_method             = aws_api_gateway_method.apigw_method_get_todo.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.backend_api_lambda.invoke_arn
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration_response" "apigw_get_todo_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_get_todo.id
  http_method = aws_api_gateway_method.apigw_method_get_todo.http_method
  status_code = aws_api_gateway_method_response.apigw_get_todo_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_get_todo_response_200, aws_api_gateway_integration.apigw_integration_get_history]
}

resource "aws_api_gateway_integration_response" "apigw_get_todo_integration_response_204" {
  rest_api_id       = aws_api_gateway_rest_api.apigw.id
  resource_id       = aws_api_gateway_resource.apigw_resource_get_todo.id
  http_method       = aws_api_gateway_method.apigw_method_get_todo.http_method
  status_code       = aws_api_gateway_method_response.apigw_get_todo_response_204.status_code
  selection_pattern = ".*'status_code': 204.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_get_todo_response_204, aws_api_gateway_integration.apigw_integration_get_history]
}

resource "aws_api_gateway_integration_response" "apigw_get_todo_integration_response_401" {
  rest_api_id       = aws_api_gateway_rest_api.apigw.id
  resource_id       = aws_api_gateway_resource.apigw_resource_get_todo.id
  http_method       = aws_api_gateway_method.apigw_method_get_todo.http_method
  status_code       = aws_api_gateway_method_response.apigw_get_todo_response_401.status_code
  selection_pattern = ".*'status_code': 401.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_get_todo_response_401, aws_api_gateway_integration.apigw_integration_get_history]
}

resource "aws_api_gateway_integration_response" "apigw_get_todo_integration_response_500" {
  rest_api_id       = aws_api_gateway_rest_api.apigw.id
  resource_id       = aws_api_gateway_resource.apigw_resource_get_todo.id
  http_method       = aws_api_gateway_method.apigw_method_get_todo.http_method
  status_code       = aws_api_gateway_method_response.apigw_get_todo_response_500.status_code
  selection_pattern = ".*'status_code': 500.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_get_todo_response_500, aws_api_gateway_integration.apigw_integration_get_history]
}

# Todo: Create
resource "aws_api_gateway_resource" "apigw_resource_create_todo" {
  parent_id   = aws_api_gateway_resource.apigw_resource_backend_api_parent.id
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  path_part   = "create"
}

resource "aws_api_gateway_method" "apigw_method_create_todo" {
  rest_api_id   = aws_api_gateway_rest_api.apigw.id
  resource_id   = aws_api_gateway_resource.apigw_resource_create_todo.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.apigw_lambda_authorizer.id
  request_parameters = {
    "method.request.header.Authorization" = true,
  }
  depends_on = [
    aws_api_gateway_authorizer.apigw_lambda_authorizer
  ]
}

resource "aws_api_gateway_method_response" "apigw_create_todo_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_create_todo.id
  http_method = aws_api_gateway_method.apigw_method_create_todo.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "apigw_create_todo_response_204" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_create_todo.id
  http_method = aws_api_gateway_method.apigw_method_create_todo.http_method
  status_code = "204"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "apigw_create_todo_response_401" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_create_todo.id
  http_method = aws_api_gateway_method.apigw_method_create_todo.http_method
  status_code = "401"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "apigw_create_todo_response_500" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_create_todo.id
  http_method = aws_api_gateway_method.apigw_method_create_todo.http_method
  status_code = "500"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "apigw_integration_create_todo" {
  rest_api_id             = aws_api_gateway_rest_api.apigw.id
  resource_id             = aws_api_gateway_resource.apigw_resource_create_todo.id
  http_method             = aws_api_gateway_method.apigw_method_create_todo.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.backend_api_lambda.invoke_arn
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration_response" "apigw_create_todo_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_create_todo.id
  http_method = aws_api_gateway_method.apigw_method_create_todo.http_method
  status_code = aws_api_gateway_method_response.apigw_create_todo_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_create_todo_response_200, aws_api_gateway_integration.apigw_integration_create_todo]
}

resource "aws_api_gateway_integration_response" "apigw_create_todo_integration_response_204" {
  rest_api_id       = aws_api_gateway_rest_api.apigw.id
  resource_id       = aws_api_gateway_resource.apigw_resource_create_todo.id
  http_method       = aws_api_gateway_method.apigw_method_create_todo.http_method
  status_code       = aws_api_gateway_method_response.apigw_create_todo_response_204.status_code
  selection_pattern = ".*'status_code': 204.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_create_todo_response_204, aws_api_gateway_integration.apigw_integration_create_todo]
}

resource "aws_api_gateway_integration_response" "apigw_create_todo_integration_response_401" {
  rest_api_id       = aws_api_gateway_rest_api.apigw.id
  resource_id       = aws_api_gateway_resource.apigw_resource_create_todo.id
  http_method       = aws_api_gateway_method.apigw_method_create_todo.http_method
  status_code       = aws_api_gateway_method_response.apigw_create_todo_response_401.status_code
  selection_pattern = ".*'status_code': 401.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_create_todo_response_401, aws_api_gateway_integration.apigw_integration_create_todo]
}

resource "aws_api_gateway_integration_response" "apigw_create_todo_integration_response_500" {
  rest_api_id       = aws_api_gateway_rest_api.apigw.id
  resource_id       = aws_api_gateway_resource.apigw_resource_create_todo.id
  http_method       = aws_api_gateway_method.apigw_method_create_todo.http_method
  status_code       = aws_api_gateway_method_response.apigw_create_todo_response_500.status_code
  selection_pattern = ".*'status_code': 500.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_create_todo_response_500, aws_api_gateway_integration.apigw_integration_create_todo]
}

# Todo: Update
resource "aws_api_gateway_resource" "apigw_resource_update_todo" {
  parent_id   = aws_api_gateway_resource.apigw_resource_backend_api_parent.id
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  path_part   = "update"
}

resource "aws_api_gateway_method" "apigw_method_update_todo" {
  rest_api_id   = aws_api_gateway_rest_api.apigw.id
  resource_id   = aws_api_gateway_resource.apigw_resource_update_todo.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.apigw_lambda_authorizer.id
  request_parameters = {
    "method.request.header.Authorization" = true,
  }
  depends_on = [
    aws_api_gateway_authorizer.apigw_lambda_authorizer
  ]
}

resource "aws_api_gateway_method_response" "apigw_update_todo_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_update_todo.id
  http_method = aws_api_gateway_method.apigw_method_update_todo.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "apigw_update_todo_response_204" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_update_todo.id
  http_method = aws_api_gateway_method.apigw_method_update_todo.http_method
  status_code = "204"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "apigw_update_todo_response_401" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_update_todo.id
  http_method = aws_api_gateway_method.apigw_method_update_todo.http_method
  status_code = "401"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "apigw_update_todo_response_500" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_update_todo.id
  http_method = aws_api_gateway_method.apigw_method_update_todo.http_method
  status_code = "500"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "apigw_integration_update_todo" {
  rest_api_id             = aws_api_gateway_rest_api.apigw.id
  resource_id             = aws_api_gateway_resource.apigw_resource_update_todo.id
  http_method             = aws_api_gateway_method.apigw_method_update_todo.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.backend_api_lambda.invoke_arn
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration_response" "apigw_update_todo_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_update_todo.id
  http_method = aws_api_gateway_method.apigw_method_update_todo.http_method
  status_code = aws_api_gateway_method_response.apigw_update_todo_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_update_todo_response_200, aws_api_gateway_integration.apigw_integration_update_todo]
}

resource "aws_api_gateway_integration_response" "apigw_update_todo_integration_response_204" {
  rest_api_id       = aws_api_gateway_rest_api.apigw.id
  resource_id       = aws_api_gateway_resource.apigw_resource_update_todo.id
  http_method       = aws_api_gateway_method.apigw_method_update_todo.http_method
  status_code       = aws_api_gateway_method_response.apigw_update_todo_response_204.status_code
  selection_pattern = ".*'status_code': 204.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_update_todo_response_204, aws_api_gateway_integration.apigw_integration_update_todo]
}

resource "aws_api_gateway_integration_response" "apigw_update_todo_integration_response_401" {
  rest_api_id       = aws_api_gateway_rest_api.apigw.id
  resource_id       = aws_api_gateway_resource.apigw_resource_update_todo.id
  http_method       = aws_api_gateway_method.apigw_method_update_todo.http_method
  status_code       = aws_api_gateway_method_response.apigw_update_todo_response_401.status_code
  selection_pattern = ".*'status_code': 401.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_update_todo_response_401, aws_api_gateway_integration.apigw_integration_update_todo]
}

resource "aws_api_gateway_integration_response" "apigw_update_todo_integration_response_500" {
  rest_api_id       = aws_api_gateway_rest_api.apigw.id
  resource_id       = aws_api_gateway_resource.apigw_resource_update_todo.id
  http_method       = aws_api_gateway_method.apigw_method_update_todo.http_method
  status_code       = aws_api_gateway_method_response.apigw_update_todo_response_500.status_code
  selection_pattern = ".*'status_code': 500.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_update_todo_response_500, aws_api_gateway_integration.apigw_integration_update_todo]
}

# Todo: delete
resource "aws_api_gateway_resource" "apigw_resource_delete_todo" {
  parent_id   = aws_api_gateway_resource.apigw_resource_backend_api_parent.id
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  path_part   = "delete"
}

resource "aws_api_gateway_method" "apigw_method_delete_todo" {
  rest_api_id   = aws_api_gateway_rest_api.apigw.id
  resource_id   = aws_api_gateway_resource.apigw_resource_delete_todo.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.apigw_lambda_authorizer.id
  request_parameters = {
    "method.request.header.Authorization" = true,
    "method.request.querystring.todo_id" = true
  }
  depends_on = [
    aws_api_gateway_authorizer.apigw_lambda_authorizer
  ]
}

resource "aws_api_gateway_method_response" "apigw_delete_todo_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_delete_todo.id
  http_method = aws_api_gateway_method.apigw_method_delete_todo.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "apigw_delete_todo_response_204" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_delete_todo.id
  http_method = aws_api_gateway_method.apigw_method_delete_todo.http_method
  status_code = "204"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "apigw_delete_todo_response_401" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_delete_todo.id
  http_method = aws_api_gateway_method.apigw_method_delete_todo.http_method
  status_code = "401"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "apigw_delete_todo_response_500" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_delete_todo.id
  http_method = aws_api_gateway_method.apigw_method_delete_todo.http_method
  status_code = "500"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "apigw_integration_delete_todo" {
  rest_api_id             = aws_api_gateway_rest_api.apigw.id
  resource_id             = aws_api_gateway_resource.apigw_resource_delete_todo.id
  http_method             = aws_api_gateway_method.apigw_method_delete_todo.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.backend_api_lambda.invoke_arn
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration_response" "apigw_delete_todo_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.apigw_resource_delete_todo.id
  http_method = aws_api_gateway_method.apigw_method_delete_todo.http_method
  status_code = aws_api_gateway_method_response.apigw_delete_todo_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_delete_todo_response_200, aws_api_gateway_integration.apigw_integration_delete_todo]
}

resource "aws_api_gateway_integration_response" "apigw_delete_todo_integration_response_204" {
  rest_api_id       = aws_api_gateway_rest_api.apigw.id
  resource_id       = aws_api_gateway_resource.apigw_resource_delete_todo.id
  http_method       = aws_api_gateway_method.apigw_method_delete_todo.http_method
  status_code       = aws_api_gateway_method_response.apigw_delete_todo_response_204.status_code
  selection_pattern = ".*'status_code': 204.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_delete_todo_response_204, aws_api_gateway_integration.apigw_integration_delete_todo]
}

resource "aws_api_gateway_integration_response" "apigw_delete_todo_integration_response_401" {
  rest_api_id       = aws_api_gateway_rest_api.apigw.id
  resource_id       = aws_api_gateway_resource.apigw_resource_delete_todo.id
  http_method       = aws_api_gateway_method.apigw_method_delete_todo.http_method
  status_code       = aws_api_gateway_method_response.apigw_delete_todo_response_401.status_code
  selection_pattern = ".*'status_code': 401.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_delete_todo_response_401, aws_api_gateway_integration.apigw_integration_delete_todo]
}

resource "aws_api_gateway_integration_response" "apigw_delete_todo_integration_response_500" {
  rest_api_id       = aws_api_gateway_rest_api.apigw.id
  resource_id       = aws_api_gateway_resource.apigw_resource_delete_todo.id
  http_method       = aws_api_gateway_method.apigw_method_delete_todo.http_method
  status_code       = aws_api_gateway_method_response.apigw_delete_todo_response_500.status_code
  selection_pattern = ".*'status_code': 500.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.apigw_delete_todo_response_500, aws_api_gateway_integration.apigw_integration_delete_todo]
}

resource "aws_api_gateway_deployment" "apigw_deployment" {

  rest_api_id = aws_api_gateway_rest_api.apigw.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.apigw.body)),
    redeploy     = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_rest_api.apigw,
    # Todo: Get
    aws_api_gateway_resource.apigw_resource_get_todo,
    aws_api_gateway_method.apigw_method_get_todo,
    aws_api_gateway_method_response.apigw_get_todo_response_200,
    aws_api_gateway_method_response.apigw_get_todo_response_204,
    aws_api_gateway_method_response.apigw_get_todo_response_401,
    aws_api_gateway_method_response.apigw_get_todo_response_500,
    aws_api_gateway_integration.apigw_integration_get_history,
    aws_api_gateway_integration_response.apigw_get_todo_integration_response_200,
    aws_api_gateway_integration_response.apigw_get_todo_integration_response_204,
    aws_api_gateway_integration_response.apigw_get_todo_integration_response_401,
    aws_api_gateway_integration_response.apigw_get_todo_integration_response_500,
    # Todo: Create
    aws_api_gateway_resource.apigw_resource_create_todo,
    aws_api_gateway_method.apigw_method_create_todo,
    aws_api_gateway_method_response.apigw_create_todo_response_200,
    aws_api_gateway_method_response.apigw_create_todo_response_204,
    aws_api_gateway_method_response.apigw_create_todo_response_401,
    aws_api_gateway_method_response.apigw_create_todo_response_500,
    aws_api_gateway_integration.apigw_integration_create_todo,
    aws_api_gateway_integration_response.apigw_create_todo_integration_response_200,
    aws_api_gateway_integration_response.apigw_create_todo_integration_response_204,
    aws_api_gateway_integration_response.apigw_create_todo_integration_response_401,
    aws_api_gateway_integration_response.apigw_create_todo_integration_response_500,
    # Todo: Update
    aws_api_gateway_resource.apigw_resource_update_todo,
    aws_api_gateway_method.apigw_method_update_todo,
    aws_api_gateway_method_response.apigw_update_todo_response_200,
    aws_api_gateway_method_response.apigw_update_todo_response_204,
    aws_api_gateway_method_response.apigw_update_todo_response_401,
    aws_api_gateway_method_response.apigw_update_todo_response_500,
    aws_api_gateway_integration.apigw_integration_update_todo,
    aws_api_gateway_integration_response.apigw_update_todo_integration_response_200,
    aws_api_gateway_integration_response.apigw_update_todo_integration_response_204,
    aws_api_gateway_integration_response.apigw_update_todo_integration_response_401,
    aws_api_gateway_integration_response.apigw_update_todo_integration_response_500,
    # Todo: delete
    aws_api_gateway_resource.apigw_resource_delete_todo,
    aws_api_gateway_method.apigw_method_delete_todo,
    aws_api_gateway_method_response.apigw_delete_todo_response_200,
    aws_api_gateway_method_response.apigw_delete_todo_response_204,
    aws_api_gateway_method_response.apigw_delete_todo_response_401,
    aws_api_gateway_method_response.apigw_delete_todo_response_500,
    aws_api_gateway_integration.apigw_integration_delete_todo,
    aws_api_gateway_integration_response.apigw_delete_todo_integration_response_200,
    aws_api_gateway_integration_response.apigw_delete_todo_integration_response_204,
    aws_api_gateway_integration_response.apigw_delete_todo_integration_response_401,
    aws_api_gateway_integration_response.apigw_delete_todo_integration_response_500,
  ]
}


resource "aws_api_gateway_stage" "apigw_prod" {
  depends_on = [
    aws_api_gateway_rest_api.apigw,
    aws_api_gateway_deployment.apigw_deployment,
    aws_cloudwatch_log_group.apigw_log_group
  ]

  deployment_id = aws_api_gateway_deployment.apigw_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.apigw.id
  stage_name    = "prod"
}

resource "aws_api_gateway_method_settings" "apigw" {
  depends_on = [
    aws_api_gateway_rest_api.apigw,
    aws_api_gateway_stage.apigw_prod
  ]

  rest_api_id = aws_api_gateway_rest_api.apigw.id
  stage_name  = aws_api_gateway_stage.apigw_prod.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"
  }
}

resource "aws_cloudwatch_log_group" "apigw_log_group" {
  depends_on = [
    aws_api_gateway_rest_api.apigw
  ]

  name              = "/aws/api-gateway/${aws_api_gateway_rest_api.apigw.name}"
  retention_in_days = 14
}
