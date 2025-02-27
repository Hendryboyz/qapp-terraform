resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.app_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "client" {
  name            = "${var.app_name}-${var.environment}-client-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.client_task.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.client_target_group.arn
    container_name   = "client-app"
    container_port   = 3000
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_container_instance.id]
    subnets          = toset(data.aws_subnets.default.ids)
    assign_public_ip = true
  }


}

resource "aws_ecs_service" "backend" {
  name            = "${var.app_name}-${var.environment}-backend-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_target_group.arn
    container_name   = "backend-app"
    container_port   = 3000
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_container_instance.id]
    subnets          = toset(data.aws_subnets.default.ids)
    assign_public_ip = true
  }
}

## Creates ECS Task Definition

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_cloudwatch_log_group" "client_log_group" {
  name              = "/${lower(var.app_name)}/ecs/client"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "client_task" {
  family                   = "${var.app_name}-${var.environment}-client-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_iam_role.arn
  cpu                      = 256
  memory                   = 512
  volume {
    name = "configs-storage"
  }
  container_definitions = jsonencode([
    {
      name      = "client-app"
      image     = "${aws_ecr_repository.client.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      # dependsOn = [
      #   {
      #     containerName = "init"
      #     condition     = "SUCCESS"
      #   }
      # ]
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "${aws_cloudwatch_log_group.client_log_group.name}",
          "awslogs-region"        = "${var.resource_region}",
          "awslogs-stream-prefix" = "qapp_client-log-stream-${var.environment}"
        }
      }
      # mountPoints = [
      #   {
      #     sourceVolume  = "configs-storage"
      #     readOnly      = false
      #     containerPath = "/app/configs"
      #   }
      # ]
    }
  ])
}

resource "aws_cloudwatch_log_group" "backend_log_group" {
  name              = "/${lower(var.app_name)}/ecs/backend"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "backend_task" {
  family                   = "${var.app_name}-${var.environment}-backend-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_iam_role.arn
  cpu                      = 256
  memory                   = 512
  volume {
    name = "configs-storage"
  }
  container_definitions = jsonencode([
    {
      name      = "backend-app"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      # dependsOn = [
      #   {
      #     containerName = "init"
      #     condition     = "SUCCESS"
      #   }
      # ]
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "${aws_cloudwatch_log_group.backend_log_group.name}",
          "awslogs-region"        = "${var.resource_region}",
          "awslogs-stream-prefix" = "qapp_backend-log-stream-${var.environment}"
        }
      }
      # mountPoints = [
      #   {
      #     sourceVolume  = "configs-storage"
      #     readOnly      = false
      #     containerPath = "/app/configs"
      #   }
      # ]
    }
  ])
}