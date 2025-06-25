resource "aws_ses_domain_identity" "ses_domain" {
  count  = var.is_ses_enabled ? 1 : 0
  domain = var.hostname
}

resource "aws_route53_record" "ses_verification_record" {
  count   = var.is_ses_enabled ? 1 : 0
  zone_id = aws_route53_zone.main.zone_id
  name    = "_amazonses.${var.hostname}"
  type    = "TXT"
  ttl     = "1800"
  records = [join("", aws_ses_domain_identity.ses_domain[*].verification_token)]
}

resource "aws_ses_domain_identity_verification" "ses_domain_verification" {
  count  = var.is_ses_enabled ? 1 : 0
  domain = join("", aws_ses_domain_identity.ses_domain[*].domain)

  depends_on = [aws_route53_record.ses_verification_record]
}

resource "aws_ses_domain_dkim" "ses_dkim" {
  count  = var.is_ses_enabled ? 1 : 0
  domain = join("", aws_ses_domain_identity.ses_domain[*].domain)
}

resource "aws_route53_record" "ses_dkim_record" {
  count   = var.is_ses_enabled ? 3 : 0
  zone_id = aws_route53_zone.main.zone_id
  name    = "${aws_ses_domain_dkim.ses_dkim[0].dkim_tokens[count.index]}._domainkey.${var.hostname}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.ses_dkim[0].dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_ses_domain_mail_from" "ses_mail_from" {
  count            = var.is_ses_enabled ? 1 : 0
  domain           = join("", aws_ses_domain_identity.ses_domain[*].domain)
  mail_from_domain = "${var.ses_from_subdomain}.${join("", aws_ses_domain_identity.ses_domain[*].domain)}"
}

resource "aws_route53_record" "amazonses_spf_record" {
  count = var.is_ses_enabled ? 1 : 0

  zone_id = aws_route53_zone.main.zone_id
  name    = join("", aws_ses_domain_mail_from.ses_mail_from[*].mail_from_domain)
  type    = "TXT"
  ttl     = "3600"
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "example_ses_domain_mail_from_mx" {
  count   = var.is_ses_enabled ? 1 : 0
  zone_id = aws_route53_zone.main.zone_id
  name    = join("", aws_ses_domain_mail_from.ses_mail_from[*].mail_from_domain)
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.resource_region}.amazonses.com"]
}
