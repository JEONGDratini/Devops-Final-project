resource "aws_ecr_repository" "my-repo" {
  name = "taskmanagement-ecr2"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecs_cluster" "my-cluster" {
  name = "Taskmanagement-cluster2"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
    weight            = 1
    base              = 1
  }
}

resource "aws_launch_configuration" "my-launch-config" {
  name          = "my-launch-config"
  image_id      = "ami-0063312c13bc1e1ad" # Amazon Linux 2 AMI
  instance_type = "m6i.large"
  security_groups = [aws_security_group.my-SG.id]
  key_name      = "hoonology"
  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER="Taskmanagement-cluster2" >> /etc/ecs/ecs.config
              EOF
}

resource "aws_autoscaling_group" "my-asg" {
  name                      = "my-asg"
  launch_configuration      = aws_launch_configuration.my-launch-config.name
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.PublicSubnet01.id]
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "my-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.my-asg.arn
    managed_scaling {
      status          = "ENABLED"
      target_capacity = 75
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 10000
    }
  }
}

# Create a task definition
resource "aws_ecs_task_definition" "my-task-definition" {
  family                   = "my-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = "arn:aws:iam::227637924508:role/ecsTaskExecutionRole"
  runtime_platform {
    cpu_architecture = "X86_64"
    operating_system_family = "LINUX"
  }
  container_definitions    = <<DEFINITION
    [
        {
            "name": "Taskmanagement_container2",
            "image": "${aws_ecr_repository.my-repo.repository_url}:latest",
            "cpu": 512,
            "memory": 1024,
            "portMappings": [
                {
                    "name": "taskmanagement_container-3000-tcp",
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
                    "awslogs-group": "/ecs/my-task-definition",
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
