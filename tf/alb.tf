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
}