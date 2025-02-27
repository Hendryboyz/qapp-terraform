## Application Load Balancer in public subnets with HTTP default listener that redirects traffic to HTTPS

resource "aws_alb" "alb" {
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
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 30
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
    matcher             = "404"
    path                = "/api"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 30
  }

  depends_on = [aws_alb.alb]
}

## Creates the Target Group listeners for client and backend targets

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client_target_group.arn
  }
}

resource "aws_lb_listener_rule" "client_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["/client/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client_target_group.arn
  }
}

resource "aws_lb_listener_rule" "backend_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 200

  condition {
    path_pattern {
      values = ["/backend/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_target_group.arn
  }
}