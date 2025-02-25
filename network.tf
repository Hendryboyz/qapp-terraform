resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default" {
  for_each          = var.subnets
  availability_zone = each.value

  tags = {
    Name = "Default subnet for ${each.value}"
  }
}

## Security Group for ECS Task Container Instances (managed by Fargate)

resource "aws_security_group" "ecs_container_instance" {
  name        = "${var.environment}_ecs-task_security-group"
  description = "Security group for ECS task running on Fargate"
  vpc_id      = aws_default_vpc.default.id

  ingress = [
    {
      description = "Allow client ingress traffic from ALB on HTTP only"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      # security_groups = [ aws_security_group.alb.id ]
      self             = true
      security_groups  = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      description = "Allow backend ingress traffic from ALB on HTTP only"
      from_port   = 4200
      to_port     = 4200
      protocol    = "tcp"
      # security_groups = [ aws_security_group.alb.id ]
      self             = true
      security_groups  = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]

  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ECS_Task_SecurityGroup_${var.environment}"
  }
}

## Creates the Target Group for our service

resource "aws_alb_target_group" "client_target_group" {
  name                 = "${var.environment}-client-targetgroup"
  port                 = 3000
  protocol             = "HTTP"
  vpc_id               = aws_default_vpc.default.id
  deregistration_delay = 5
  target_type          = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 60
    # matcher             = var.healthcheck_matcher
    # path                = var.healthcheck_endpoint
    port     = "traffic-port"
    protocol = "HTTP"
    timeout  = 30
  }

  # depends_on = [aws_alb.alb]
}

resource "aws_alb_target_group" "backend_target_group" {
  name                 = "${var.environment}-backend-targetgroup"
  port                 = 3000
  protocol             = "HTTP"
  vpc_id               = aws_default_vpc.default.id
  deregistration_delay = 5
  target_type          = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 60
    # matcher             = var.healthcheck_matcher
    # path                = var.healthcheck_endpoint
    port     = "traffic-port"
    protocol = "HTTP"
    timeout  = 30
  }

  # depends_on = [aws_alb.alb]
}