resource "aws_cloudwatch_event_rule" "DynamoDBLogEventBridgeTF" {
  name        = "DynamoDBLogEventBridgeTF"
  description = "EventBridge triggered by DynamoDB events"
  event_pattern = jsonencode({
    "source": [
      "aws.dynamodb"
    ]
  })
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.LogLambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.DynamoDBLogEventBridgeTF.arn
}

resource "aws_cloudwatch_event_target" "DynamoDBLogEventBridgeTF_target" {
  rule      = aws_cloudwatch_event_rule.DynamoDBLogEventBridgeTF.name
  target_id = "LogLambdaTarget"
  arn       = aws_lambda_function.LogLambda.arn
}