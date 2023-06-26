# 3. Lambda

# 람다 함수 생성 

resource "aws_lambda_function" "userLambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "userLambda"
  role          = aws_iam_role.lambda_iam.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  runtime = "nodejs14.x"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.dynamodb_user.name
    }
  }
}



# IAM 역할 생성
resource "aws_iam_role" "lambda_iam" {
  name = "lambdaIAM"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# IAM - CloudWatch Log 기록 
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_iam.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# IAM 정책 생성 (  Lambda 함수가 DynamoDB 테이블에 액세스 )
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambdaPolicy"
  role = aws_iam_role.lambda_iam.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Effect = "Allow",
        Resource = aws_dynamodb_table.dynamodb_user.arn
      },
    ]
  })
}



