resource "aws_ecr_repository" "my-repo" {
  name = "taskmanagement-ecr2"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecs_cluster" "my-cluster" {
  name = "Taskmanagement-cluster2"
}

resource "aws_instance" "ecs_ec2" {
  ami                    = "ami-0c9c942bd7bf113a2" # Amazon Linux 2 AMI
  instance_type          = "m6i.large"
  subnet_id              = aws_subnet.PublicSubnet01.id
  vpc_security_group_ids = [aws_security_group.my-SG.id]
  user_data              = <<-EOF
                            #!/bin/bash
                            echo ECS_CLUSTER=${aws_ecs_cluster.my-cluster.name} >> /etc/ecs/ecs.config
                            EOF

  tags = {
    Name = "ecs-ec2"
  }
}

# Create a task definition
resource "aws_ecs_task_definition" "my-task-definition" {
  family                   = "my-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn = "arn:aws:iam::227637924508:role/ecsTaskExecutionRole"
  container_definitions    = <<DEFINITION
    [
        {
            "name": "Taskmanagement_container2",
            "image": "${aws_ecr_repository.my-repo.repository_url}:latest",
            "memory": 512,
            "cpu": 256,
            "portMappings": [
                {
                    "containerPort": 3000,
                    "hostPort": 3000,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "environment": [],
            "mountPoints": [],
            "volumesFrom": [],
            "secrets": [
                {
                    "name": "AWS_SECRET_ACCESS_KEY",
                    "valueFrom": "arn:aws:secretsmanager:ap-northeast-2:227637924508:secret:Task_AWS-xgI83w:AWS_SECRET_ACCESS_KEY::"
                },
                {
                    "name": "DB_NAME",
                    "valueFrom": "arn:aws:secretsmanager:ap-northeast-2:227637924508:secret:Task_RDS-HQTjbb:DB_NAME::"
                },
                {
                    "name": "DB_HOST",
                    "valueFrom": "arn:aws:secretsmanager:ap-northeast-2:227637924508:secret:Task_RDS-HQTjbb:DB_HOST::"
                },
                {
                    "name": "DB_USER",
                    "valueFrom": "arn:aws:secretsmanager:ap-northeast-2:227637924508:secret:Task_RDS-HQTjbb:DB_USER::"
                },
                {
                    "name": "AWS_ACCESS_KEY_ID",
                    "valueFrom": "arn:aws:secretsmanager:ap-northeast-2:227637924508:secret:Task_AWS-xgI83w:AWS_ACCESS_KEY_ID::"
                },
                {
                    "name": "DB_PASSWORD",
                    "valueFrom": "arn:aws:secretsmanager:ap-northeast-2:227637924508:secret:Task_RDS-HQTjbb:DB_PASSWORD::"
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-group": "/ecs/Taskmanagement_def",
                    "awslogs-region": "ap-northeast-2",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
    ]
  DEFINITION
  
}

# Create a service
resource "aws_ecs_service" "my-service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my-cluster.id
  task_definition = aws_ecs_task_definition.my-task-definition.arn
  desired_count   = 1
  launch_type     = "EC2"
  
  network_configuration {
    subnets          = [aws_subnet.PublicSubnet01.id]
    security_groups  = [aws_security_group.my-SG.id]
  }
}
