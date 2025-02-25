resource "aws_s3_bucket" "config_bucket" {
  bucket = "${var.app_name}-${var.environment}-configs-bucket"

  tags = {
    Environment = var.environment
  }
}