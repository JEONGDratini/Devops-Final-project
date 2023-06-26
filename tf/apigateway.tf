# API Gateway - REST API 생성
resource "aws_api_gateway_rest_api" "authorization_api" {
  name        = "authorization-api"
  description = "Terraform API Gateway"
    endpoint_configuration {
    types = ["REGIONAL"]
  }
}

/* REGIONAL: REGIONAL API는 API를 생성한 지역에 배포됩니다.
클라이언트가 REGIONAL API를 호출하면 요청이 API를 배포한 지역으로 직접 이동합니다.
이는 클라이언트가 모두 같은 지역에 있거나 API의 캐싱 설정 및 배포를 더 많이 제어하려는 경우에 유용할 수 있습니다.
또한 대부분의 요청이 동일한 리전 내에서 오는 경우 더 비용 효율적일 수 있습니다. */


# =========================================================================
# GET - '/' 레벨
resource "aws_api_gateway_method" "get_root_method" {
  rest_api_id   = aws_api_gateway_rest_api.authorization_api.id
  resource_id   = aws_api_gateway_rest_api.authorization_api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

# Configure integrations for the GET methods
resource "aws_api_gateway_integration" "get_root_integration" {
  rest_api_id = aws_api_gateway_rest_api.authorization_api.id
  resource_id = aws_api_gateway_rest_api.authorization_api.root_resource_id
  http_method = aws_api_gateway_method.get_root_method.http_method
  type                 = "HTTP_PROXY"
  uri                  = "http://${aws_alb.my_alb.dns_name}/"
  integration_http_method = "GET"
}

# POST - '/' 레벨 
resource "aws_api_gateway_method" "post_root_method" {
  rest_api_id   = aws_api_gateway_rest_api.authorization_api.id
  resource_id   = aws_api_gateway_rest_api.authorization_api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

# Configure integrations for the POST methods
resource "aws_api_gateway_integration" "post_root_integration" {
  rest_api_id          = aws_api_gateway_rest_api.authorization_api.id
  resource_id          = aws_api_gateway_rest_api.authorization_api.root_resource_id
  http_method          = aws_api_gateway_method.post_root_method.http_method
  type                 = "HTTP_PROXY"
  uri                  = "http://${aws_alb.my_alb.dns_name}/"
  integration_http_method = "POST"
}

# =========================================================================
# DynamoDB 리소스 '/dynamodb_user'
resource "aws_api_gateway_resource" "dynamodb_user_resource" {
  rest_api_id = aws_api_gateway_rest_api.authorization_api.id
  parent_id   = aws_api_gateway_rest_api.authorization_api.root_resource_id
  path_part   = "dynamodb_user"
}

resource "aws_api_gateway_integration" "post_dynamodb_user_integration" {
  rest_api_id             = aws_api_gateway_rest_api.authorization_api.id
  resource_id             = aws_api_gateway_resource.dynamodb_user_resource.id
  http_method             = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.userLambda.invoke_arn
  integration_http_method = "POST"
}



# POST - '/dynamodb_user' 레벨
resource "aws_api_gateway_method" "post_dynamodb_user_method" {
  rest_api_id   = aws_api_gateway_rest_api.authorization_api.id
  resource_id   = aws_api_gateway_resource.dynamodb_user_resource.id
  http_method   = "POST"
  authorization = "NONE"
}



# OPTIONS - '/dynamodb_user' 레벨
resource "aws_api_gateway_method" "options_dynamodb_user_method" {
  rest_api_id   = aws_api_gateway_rest_api.authorization_api.id
  resource_id   = aws_api_gateway_resource.dynamodb_user_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Configure integrations for the OPTIONS methods
resource "aws_api_gateway_integration" "options_dynamodb_user_integration" {
  rest_api_id = aws_api_gateway_rest_api.authorization_api.id
  resource_id = aws_api_gateway_resource.dynamodb_user_resource.id
  http_method = "OPTIONS"
  type        = "MOCK"
}

# =========================================================================

# 태스크 리소스 '{Task_id}'
resource "aws_api_gateway_resource" "task_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.authorization_api.id
  parent_id   = aws_api_gateway_rest_api.authorization_api.root_resource_id
  path_part   = "{Task_id}"
}

# DELETE - '/{Task_id}' 레벨 
resource "aws_api_gateway_method" "delete_task_id_method" {
  rest_api_id   = aws_api_gateway_rest_api.authorization_api.id
  resource_id   = aws_api_gateway_resource.task_id_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# Configure integrations for the DELETE methods
resource "aws_api_gateway_integration" "delete_task_id_integration" {
  rest_api_id          = aws_api_gateway_rest_api.authorization_api.id
  resource_id          = aws_api_gateway_resource.task_id_resource.id
  http_method          = aws_api_gateway_method.delete_task_id_method.http_method
  type                 = "HTTP_PROXY"
  uri                  = "http://${aws_alb.my_alb.dns_name}/{proxy}"
  integration_http_method = "DELETE"
}

# PUT - '/{Task_id}' 레벨 
resource "aws_api_gateway_method" "put_task_id_method" {
  rest_api_id   = aws_api_gateway_rest_api.authorization_api.id
  resource_id   = aws_api_gateway_resource.task_id_resource.id
  http_method   = "PUT"
  authorization = "NONE"
}

# Configure integrations for the PUT methods
resource "aws_api_gateway_integration" "put_task_id_integration" {
  rest_api_id          = aws_api_gateway_rest_api.authorization_api.id
  resource_id          = aws_api_gateway_resource.task_id_resource.id
  http_method          = aws_api_gateway_method.put_task_id_method.http_method
  type                 = "HTTP_PROXY"
  uri                  = "http://${aws_alb.my_alb.dns_name}/{proxy}"
  integration_http_method = "PUT"
}




# CORS 활성화
resource "aws_api_gateway_method" "cors_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.authorization_api.id
  resource_id   = aws_api_gateway_rest_api.authorization_api.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.authorization_api.id
  resource_id             = aws_api_gateway_rest_api.authorization_api.root_resource_id
  http_method             = aws_api_gateway_method.cors_options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "cors_options_response" {
  rest_api_id = aws_api_gateway_rest_api.authorization_api.id
  resource_id = aws_api_gateway_rest_api.authorization_api.root_resource_id
  http_method = aws_api_gateway_method.cors_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "cors_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.authorization_api.id
  resource_id = aws_api_gateway_rest_api.authorization_api.root_resource_id
  http_method = aws_api_gateway_method.cors_options_method.http_method
  status_code = aws_api_gateway_method_response.cors_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

