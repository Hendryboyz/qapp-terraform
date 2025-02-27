resource "aws_route53_zone" "main" {
  name = var.hostname

  tags = {
    Environment = var.environment
  }
}

resource "aws_route53_record" "www_alb" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.hostname
  type    = "A"

  alias {
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
    evaluate_target_health = true
  }
}