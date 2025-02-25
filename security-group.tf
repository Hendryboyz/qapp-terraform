## Security Group for ECS Task Container Instances (managed by Fargate)

resource "aws_security_group" "ecs_container_instance" {
  name        = "${var.app_name}-${var.environment}-ecs_task-security_group"
  description = "Security group for ECS task running on Fargate"
  vpc_id      = aws_default_vpc.default.id

  ingress = [
    {
      description      = "Allow client ingress traffic from ALB on HTTP only"
      from_port        = 3000
      to_port          = 3000
      protocol         = "tcp"
      security_groups  = [aws_security_group.alb.id]
      self             = true
      security_groups  = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      cidr_blocks      = []
    },
    {
      description      = "Allow backend ingress traffic from ALB on HTTP only"
      from_port        = 4200
      to_port          = 4200
      protocol         = "tcp"
      security_groups  = [aws_security_group.alb.id]
      self             = true
      security_groups  = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      cidr_blocks      = []
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
    Name        = "${var.app_name}-${var.environment}-ECS_Task-SecurityGroup"
    Environment = var.environment
  }
}

## Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-${var.environment}-alb-security_group"
  description = "Security group for ALB"
  vpc_id      = aws_default_vpc.default.id

  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-ALB-SecurityGroup"
    Environment = var.environment
  }
}
