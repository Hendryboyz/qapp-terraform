resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.app_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}


resource "aws_ecs_service" "client" {
  name        = "${var.app_name}-${var.environment}-client-service"
  cluster     = aws_ecs_cluster.app_cluster.id
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_alb_target_group.client_target_group.arn
    container_name   = "client-app"
    container_port   = 4200
  }

  network_configuration {
    security_groups = [aws_security_group.ecs_container_instance.id]
    subnets         = toset(data.aws_subnets.default.ids)
    # assign_public_ip = false
  }
}

resource "aws_ecs_service" "backend" {
  name        = "${var.app_name}-${var.environment}-backend-service"
  cluster     = aws_ecs_cluster.app_cluster.id
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_alb_target_group.backend_target_group.arn
    container_name   = "backend-app"
    container_port   = 3000
  }

  network_configuration {
    security_groups = [aws_security_group.ecs_container_instance.id]
    subnets         = toset(data.aws_subnets.default.ids)
    # assign_public_ip = false
  }
}

## Creates ECS Task Definition

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_ecs_task_definition" "client_task" {
  family                   = "${var.app_name}-${var.environment}-client-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_iam_role.arn
  cpu                      = 5
  memory                   = 256
  container_definitions = jsonencode([
    {
      name      = "client-app"
      image     = "${aws_ecr_repository.client.repository_url}:latest"
      cpu       = 5
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 4200
          hostPort      = 4200
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "backend_task" {
  family                   = "${var.app_name}-${var.environment}-backend-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_iam_role.arn
  cpu                      = 5
  memory                   = 256
  container_definitions = jsonencode([
    {
      name      = "backend-app"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      cpu       = 5
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
}