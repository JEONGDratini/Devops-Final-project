module "apigateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "2.2.2"

  create_api_domain_name = false

  name          = "Task-management API-tf"
  description   = "Task-management API created by terraform"
  protocol_type = "HTTP"

#cors 설정. 테스트를 위해서 모든 헤더와 메서드, 송신자를 허용한다.
  cors_configuration = {
    allow_headers = ["*"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  default_route_settings = {
    data_trace_enabled       = true
    detailed_metrics_enabled = true
    logging_level            = "INFO"
    throttling_burst_limit   = 5000
    throttling_rate_limit    = 10000
  }

  integrations = {
    "POST /user" = {
      lambda_arn             = "[람다 ARN을 입력하세요]"
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
    }

    "GET /" = {
      connection_type    = "VPC_LINK"
      vpc_link           = "my-vpc-Link"
      integration_uri    = "[로드밸런서의 리스너 ARN을 입력하세요]"
      integration_type   = "HTTP_PROXY"
      integration_method = "GET"
    }

    "POST /" = {
      connection_type    = "VPC_LINK"
      vpc_link           = "my-vpc-Link"
      integration_uri    = "[로드밸런서의 리스너 ARN을 입력하세요]"
      integration_type   = "HTTP_PROXY"
      integration_method = "POST"
    }

    "PUT /{Task_id}" = {
      connection_type    = "VPC_LINK"
      vpc_link           = "my-vpc-Link"
      integration_uri    = "[로드밸런서의 리스너 ARN을 입력하세요]"
      integration_type   = "HTTP_PROXY"
      integration_method = "PUT"
    }

    "DELETE /{Task_id}" = {
      connection_type    = "VPC_LINK"
      vpc_link           = "my-vpc-Link"
      integration_uri    = "[로드밸런서의 리스너 ARN을 입력하세요]"
      integration_type   = "HTTP_PROXY"
      integration_method = "DELETE"
    }
  }

#VPC에 의해서 외부로부터 보호받고있는 ALB에 연결하기 위해서 
  vpc_links = {
    my-vpc-Link = {
      name               = "Task-VPC-Link-tf"
      security_group_ids = ["서브넷 아이디 입력하세요"] # 내가 연결하고싶은 vpc의 서브넷에 연결한다.
      subnet_ids         = ["서브넷 아이디 입력하세요", "서브넷 아이디 입력하세요"]
    }
  }
