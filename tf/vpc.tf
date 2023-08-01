resource "aws_vpc" "my-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags       = {
        Name = "Terraform VPC"
    }
}

# create subnet
resource "aws_subnet" "PublicSubnet01" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "my-public-subnet01"
  }
}

resource "aws_subnet" "PublicSubnet02" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "my-public-subnet02"
  }
}
resource "aws_subnet" "PrivateSubnet01" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"
  
  tags = {
    Name = "my-private-subnet01"
  }
}
resource "aws_subnet" "PrivateSubnet02" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2c"
  
  tags = {
    Name = "my-private-subnet02"
  }
}

# 인터넷 게이트웨이 ( 외부 인터넷에 연결하기 위함 )
resource "aws_internet_gateway" "my-IGW" {
  vpc_id = aws_vpc.my-vpc.id
}

# 라우팅 테이블
## 1. 퍼블릭 라우팅 테이블 정의
resource "aws_route_table" "my-public-route" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-IGW.id
  }
}

## 퍼블릭 라우팅 테이블 연결
resource "aws_route_table_association" "my-public-RT-Assoication01" {
  subnet_id = aws_subnet.PublicSubnet01.id
  route_table_id = aws_route_table.my-public-route.id
}
resource "aws_route_table_association" "my-public-RT-Assoication02" {
  subnet_id = aws_subnet.PublicSubnet02.id
  route_table_id = aws_route_table.my-public-route.id
}

## 보안 그룹
resource "aws_security_group" "my-SG" {
  vpc_id = aws_vpc.my-vpc.id
  name = "my SG"
  description = "my SG"
  tags = {
    Name = "my SG"
  }
}

## 보안 그룹 규칙
resource "aws_security_group_rule" "my-ingress-rule-22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my-SG.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "my-ingress-rule-80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my-SG.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "my-ingress-rule-443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my-SG.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "my-ingress-rule-3000" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my-SG.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "my-ingress-rule-3306" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my-SG.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "my-egress-rule" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my-SG.id
  lifecycle {
    create_before_destroy = true
  }
}

#vpc 엔드포인트
resource "aws_vpc_endpoint" "my-vpc-endpoint" {
  vpc_id              = aws_vpc.my-vpc.id
  service_name        = "com.amazonaws.ap-northeast-2.dynamodb"
  vpc_endpoint_type   = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "my_vpc_endpoint_rt_association" {
  vpc_endpoint_id = aws_vpc_endpoint.my-vpc-endpoint.id
  route_table_id  = aws_route_table.my-public-route.id
}