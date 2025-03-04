resource "aws_acm_certificate" "alb_certificate" {
  domain_name               = var.hostname
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.hostname}"]

  tags = {
    Environment = var.environment
  }
}

resource "aws_acm_certificate_validation" "alb_certificate" {
  certificate_arn         = aws_acm_certificate.alb_certificate.arn
  validation_record_fqdns = [aws_route53_record.generic_certificate_validation.fqdn]
}