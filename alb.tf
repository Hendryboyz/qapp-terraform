## Application Load Balancer in public subnets with HTTP default listener that redirects traffic to HTTPS

resource "aws_alb" "alb" {
  name            = "${var.app_name}-${var.environment}-alb"
  security_groups = [aws_security_group.alb.id]
  subnets         = toset(data.aws_subnets.default.ids)

  tags = {
    Environment = var.environment
  }
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

  tags = {
    Environment = var.environment
  }

  depends_on = [aws_alb.alb]
}

resource "aws_lb_target_group" "backoffice_target_group" {
  name                 = "${var.app_name}-${var.environment}-backoffice-targetgroup"
  port                 = 80
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

  tags = {
    Environment = var.environment
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
    path                = "/backend/api"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 30
  }

  tags = {
    Environment = var.environment
  }

  depends_on = [aws_alb.alb]
}

## Creates the Target Group listeners for client and backend targets

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.alb_certificate.arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.client_target_group.arn
  }

  tags = {
    Environment = var.environment
  }

  depends_on = [aws_acm_certificate.alb_certificate]
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

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_listener_rule" "backoffice_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 300

  condition {
    path_pattern {
      values = ["/bo/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backoffice_target_group.arn
  }

  tags = {
    Environment = var.environment
  }
}
