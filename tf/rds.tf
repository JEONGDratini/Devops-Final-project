# # RDS 서브넷 그룹 생성
# resource "aws_db_subnet_group" "PrivateSubnet-gr" {
#   name       = "privatesubnet-gr"
#   subnet_ids = [aws_subnet.PrivateSubnet01.id, aws_subnet.PrivateSubnet02.id] # RDS가 위치할 서브넷 ID
# }

# # RDS DB 파라미터 그룹 생성
# resource "aws_db_parameter_group" "project-rds-params" {
#   name   = "project-rds-params"
#   family = "mysql8.0"

#   # 파라미터 설정
#   parameter {
#     name  = "character_set_server"
#     value = "utf8"
#   }

#   parameter {
#     name  = "character_set_client"
#     value = "utf8"
#   }
# }

# # RDS인스턴스 생성
# resource "aws_db_instance" "task-database-mk2" {
#   identifier           = "task-database-mk2"
#   allocated_storage    = 20
#   engine               = "mysql"
#   engine_version       = "8.0.32"
#   instance_class       = "db.t2.micro"
#   username             = var.DB_USER
#   password             = var.DB_PASSWORD
#   parameter_group_name = aws_db_parameter_group.project-rds-params.name
#   db_subnet_group_name = aws_db_subnet_group.PrivateSubnet-gr.name
#   vpc_security_group_ids = [aws_security_group.my-private-SG.id]
#   skip_final_snapshot  = true
# }

# # 보안 그룹
# resource "aws_security_group" "my-private-SG" {
#   vpc_id = aws_vpc.my-vpc.id
#   name = "my-private-SG"
#   description = "my private SG"
#   tags = {
#     Name = "log private SG"
#   }
# }

# resource "aws_security_group_rule" "my-ingress-rule2-3306" {
#   type              = "ingress"
#   from_port         = 3306
#   to_port           = 3306
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.my-private-SG.id

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_security_group_rule" "my-egress-rule-3306" {
#   type              = "egress"
#   from_port         = 3306
#   to_port           = 3306
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.my-private-SG.id

#   lifecycle {
#     create_before_destroy = true
#   }
# }