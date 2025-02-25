## Application Load Balancer in public subnets with HTTP default listener that redirects traffic to HTTPS

resource "aws_alb" "alb" {
count = 0
  name            = "${var.app_name}-${var.environment}-alb"
  security_groups = [aws_security_group.alb.id]
  subnets         = toset(data.aws_subnets.default.ids)
}

## Creates the Target Group for our service

resource "aws_lb_target_group" "client_target_group" {
  name                 = "${var.app_name}-${var.environment}-client-targetgroup"
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

  depends_on = [aws_alb.alb]
}

resource "aws_lb_target_group" "backend_target_group" {
  name                 = "${var.app_name}-${var.environment}-backend-targetgroup"
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

  depends_on = [aws_alb.alb]
}

## Creates the Target Group listeners for client and backend targets
