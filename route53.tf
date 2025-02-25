resource "aws_route53_zone" "main" {
  name = var.hostname

  tags = {
    Environment = var.environment
  }
}