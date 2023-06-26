resource "aws_alb" "my_alb" {
  name = "Taskmanagement-ALB2"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.my-SG.id]
  subnets = [aws_subnet.PublicSubnet01.id, aws_subnet.PublicSubnet02.id]
  enable_cross_zone_load_balancing = true
}


resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_alb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-target-group.arn
  }
}

resource "aws_lb_target_group" "my-target-group" {
  name     = "Taskmanagement-TG2"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.my-vpc.id

  target_type = "ip"

  health_check {
  enabled             = true          # 헬스 체크 활성화
  interval            = 30            # 헬스 체크 간격(초)
  path                = "/"           # 헬스 체크에 사용할 경로
  protocol            = "HTTP"        # 사용할 프로토콜
  timeout             = 5             # 각 헬스 체크에 대한 타임아웃(초)
  healthy_threshold   = 3             # 건강한 상태로 판단하기 전에 연속적으로 통과해야 하는 헬스 체크 수
  unhealthy_threshold = 3             # 건강하지 않은 상태로 판단하기 전에 연속적으로 실패해야 하는 헬스 체크 수
  matcher             = "200-299"     # 헬스 체크 응답에 대한 HTTP 상태 코드
  }
}