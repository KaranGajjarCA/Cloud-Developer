resource "null_resource" "lambda_layer" {
  triggers = {
    always_run = timestamp()
  }
  # the command to install python and dependencies to the machine and zips
  provisioner "local-exec" {
    command = <<EOT
        echo "creating layers with requirements.txt packages..."

        cd ../../packages
        rm -rf python
        mkdir python
        cd python

        # Installing python dependencies...
        pip3 install --platform manylinux2014_x86_64 --implementation cp --python 3.9 --only-binary=:all: --upgrade --target=./ -r ../../requirements.txt
        cd ..
        src chmod 644 $(find python -type f)
        src chmod 755 $(find python -type d)
        zip -r layer.zip ./

        #deleting the python dist package modules
        rm -rf python
    EOT
  }
}


resource "aws_lambda_layer_version" "deployment_lambda_layer" {
  compatible_runtimes = ["python3.9"]
  filename            = "../../packages/layer.zip"
  description         = "Package Lambda Layer"
  layer_name          = "PackageLayer"
  depends_on          = [null_resource.lambda_layer]
}


data "archive_file" "backend_lambda_zip" {
  type        = "zip"
  source_dir  = "../../src"
  output_path = "${path.module}/lambda/lambda.zip"
}



resource "aws_lambda_function" "backend_api_lambda" {
  filename      = data.archive_file.backend_lambda_zip.output_path
  function_name = "backend_api"
  role          = aws_iam_role.lambda_role.arn
  handler       = "backend_api.main.handler"
  runtime       = "python3.9"
  layers        = [aws_lambda_layer_version.deployment_lambda_layer.arn]
  environment {
    variables = local.lambda_env_vars
  }
  depends_on = [aws_lambda_layer_version.deployment_lambda_layer, aws_dynamodb_table.dynamodb]
}


resource "aws_lambda_function" "backend_api_authorizer_lambda" {
  filename      = data.archive_file.backend_lambda_zip.output_path
  function_name = "backend_api_authorizer"
  role          = aws_iam_role.lambda_role.arn
  handler       = "authorizer.main.handler"
  runtime       = "python3.9"
  layers        = [aws_lambda_layer_version.deployment_lambda_layer.arn]
  depends_on    = [aws_lambda_layer_version.deployment_lambda_layer]
}

resource "aws_cloudwatch_log_group" "lambda_log_group_backend_api" {
  name              = "/aws/lambda/backend_api"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "lambda_log_group_backend_api_authorizer" {
  name              = "/aws/lambda/backend_api_authorizer"
  retention_in_days = 14
}

resource "aws_lambda_permission" "allow_cloudwatch_authorizer" {
  action        = "lambda:InvokeFunction"
  function_name = "backend_api_authorizer"
  principal     = "logs.${var.region}.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.lambda_log_group_backend_api_authorizer.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "lambda:InvokeFunction"
  function_name = "backend_api"
  principal     = "logs.${var.region}.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.lambda_log_group_backend_api.arn
}