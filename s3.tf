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

resource "aws_s3_bucket_lifecycle_configuration" "tmp_assets_lifecycle" {
  bucket = aws_s3_bucket.assets_bucket.id

  rule {
    id     = "expire_tmp_objects"
    status = "Enabled"

    filter {
      prefix = "tmp/"
    }

    expiration {
      days = 1 # Deletes objects after 1 day
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "assets_bucket_ownership" {
  bucket = aws_s3_bucket.assets_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "assets_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.assets_bucket.id}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.assets_s3_distribution.id}"]
    }
  }

  statement {
    sid    = "AllowIAMIdentityReadWrite"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ecs_task_execution_role.arn, aws_iam_user.local_developer.arn]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.assets_bucket.id}",
      "arn:aws:s3:::${aws_s3_bucket.assets_bucket.id}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "assets_bucket_policy" {
  bucket = aws_s3_bucket.assets_bucket.id
  policy = data.aws_iam_policy_document.assets_bucket_policy.json
}
