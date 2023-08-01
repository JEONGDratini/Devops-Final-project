# 2. DynamoDB

resource "aws_dynamodb_table" "dynamodb_user" {
  name           = "dynamodb_user"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "email"
  range_key      = "password"

    attribute {
    name = "email"
    type = "S"
  }

   attribute {
    name = "password"
    type = "S"
  }
}

resource "aws_dynamodb_table" "Dynamo_Log_tf" {
  name           = "Dynamo_Log_tf"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "Timestamp"
  range_key      = "LogType"

  attribute {
    name = "Timestamp"
    type = "S"
  }

  attribute {
    name = "LogType"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name = "Dynamo_Log_tf"
  }
}