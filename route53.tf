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

resource "aws_route53_zone" "demo" {
  count = var.is_demo_page_enabled ? 1 : 0

  name = "v2.${var.hostname}"

  tags = {
    Environment = var.environment
  }

  depends_on = [aws_route53_zone.main]
}

resource "aws_route53_record" "demo_ns_to_main" {
  count = var.is_demo_page_enabled ? 1 : 0

  zone_id = aws_route53_zone.main.zone_id
  name    = "v2.${var.hostname}"
  type    = "NS"
  ttl     = "300"
  
  records = aws_route53_zone.demo[0].name_servers

  depends_on = [aws_route53_zone.demo]
}

resource "aws_route53_record" "demo_alb" {
  count = var.is_demo_page_enabled ? 1 : 0

  zone_id = aws_route53_zone.demo[0].zone_id
  name    = "v2.${var.hostname}"
  type    = "A"

  alias {
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_route53_zone.demo]
}

# assets_cloudfront_certificate apply the same validation record as alb_certificate
resource "aws_route53_record" "generic_certificate_validation" {
  name    = tolist(aws_acm_certificate.alb_certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.alb_certificate.domain_validation_options)[0].resource_record_type
  zone_id = aws_route53_zone.main.id
  records = [tolist(aws_acm_certificate.alb_certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 300
}

resource "aws_route53_record" "ipv4_assets_cloudfront" {
  zone_id = aws_route53_zone.main.id
  name    = "assets.${var.hostname}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.assets_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.assets_s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

# resource "aws_route53_record" "ipv6_assets_cloudfront" {
#   zone_id = aws_route53_zone.main.id
#   name    = "assets.${var.hostname}"
#   type    = "AAAA"

#   alias {
#     name                   = aws_cloudfront_distribution.assets_s3_distribution.domain_name
#     zone_id                = aws_cloudfront_distribution.assets_s3_distribution.hosted_zone_id
#     evaluate_target_health = true
#   }
# }