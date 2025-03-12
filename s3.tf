resource "aws_s3_bucket" "config_bucket" {
  bucket = "${var.app_name}-${var.environment}-configs-bucket"

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "assets_bucket" {
  bucket = "${var.app_name}-${var.environment}-assets-bucket"

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_cors_configuration" "assets_bucket_cors" {
  bucket = aws_s3_bucket.assets_bucket.id

  cors_rule {
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["https://${var.hostname}"]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}