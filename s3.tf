resource "aws_s3_bucket" "config_bucket" {
  bucket = "${var.app_name}-configs-bucket"

  tags = {
    Environment = var.environment
  }
}