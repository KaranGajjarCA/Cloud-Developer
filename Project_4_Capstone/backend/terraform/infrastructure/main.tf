provider "aws" {
  region = var.region
}

provider "aws" {
  region = "us-west-2"
  alias  = "replica"
}



resource "aws_kms_key" "basic_key" {
  multi_region = true
}

resource "aws_kms_alias" "basic_key" {
  name          = "alias/basic-data-kms-key"
  target_key_id = aws_kms_key.basic_key.key_id

}

resource "aws_kms_replica_key" "basic_key" {
  primary_key_arn = aws_kms_key.basic_key.arn
  provider        = aws.replica
}

resource "aws_kms_alias" "basic_key_replica" {
  name          = "alias/basic-data-kms-key-replica"
  target_key_id = aws_kms_replica_key.basic_key.key_id
}


data "aws_kms_key" "primary" {
  key_id     = aws_kms_alias.basic_key.name
  depends_on = [aws_kms_alias.basic_key]
}