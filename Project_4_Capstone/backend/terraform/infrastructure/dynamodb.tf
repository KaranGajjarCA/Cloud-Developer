data "aws_kms_alias" "alias" {
  count      = 1
  name       = aws_kms_alias.basic_key.name
  depends_on = [aws_kms_alias.basic_key]
}


resource "aws_dynamodb_table" "dynamodb" {
  name         = "todo-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "todo_id"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = data.aws_kms_alias.alias[0].target_key_arn
  }

}