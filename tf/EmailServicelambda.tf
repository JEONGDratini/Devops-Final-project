resource "aws_lambda_function" "LogLambda" {
  filename      = "EmailServiceLambda.zip"
  function_name = "EmailService"
  role          = aws_iam_role.EmailService_iam.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256("EmailServiceLambdaInit.zip")

  runtime = "nodejs14.x"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.dynamodb_log.name
    }
  }
}

resource "aws_dynamodb_table" "dynamodb_log" {
  name           = "dynamodb_log"
  billing_mode   = "PAY_PER_REQUEST"
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
}

resource "aws_iam_role" "EmailService_iam" {
  name = "EmailServiceIAM"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "EmailService_logs" {
  role       = aws_iam_role.EmailService_iam.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "EmailService_policy" {
  name = "EmailServicePolicy"
  role = aws_iam_role.EmailService_iam.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.dynamodb_log.arn
      },
    ]
  })
}