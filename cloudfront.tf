resource "aws_cloudfront_origin_access_control" "assets_bucket_oac" {
  name                              = "${var.app_name}-${var.environment}-assets-bucket-oac"
  description                       = "origin access control for assets bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" "app_cors_policy" {
  name    = "${var.app_name}-${var.environment}-cors-policy"
  comment = "qapp client/backoffice cors policy"

  cors_config {
    access_control_allow_credentials = false

    access_control_allow_headers {
      items = ["*"]
    }

    access_control_expose_headers {
      items = ["ETag"]
    }

    access_control_allow_methods {
      items = ["GET", "POST", "PUT"]
    }

    access_control_allow_origins {
      items = ["${var.hostname}"]
    }

    access_control_max_age_sec = 3000

    origin_override = true
  }
}

locals {
  s3_origin_id = "${var.app_name}-${var.environment}-assets-s3-origin"
}

resource "aws_cloudfront_distribution" "assets_s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.assets_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.assets_bucket_oac.id
    origin_id                = local.s3_origin_id
  }

  is_ipv6_enabled = true
  enabled         = true

  aliases = ["assets.${var.hostname}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    response_headers_policy_id = aws_cloudfront_response_headers_policy.app_cors_policy.id
    viewer_protocol_policy     = "allow-all"
    min_ttl                    = 0
    default_ttl                = 1800
    max_ttl                    = 3600
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP", "TW", "NG"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.assets_cloudfront_certificate.arn
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  tags = {
    Environment = var.environment
  }

  depends_on = [ aws_acm_certificate.assets_cloudfront_certificate, aws_acm_certificate_validation.assets_cloudfront_certificate ]
}