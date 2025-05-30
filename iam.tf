resource "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

## IAM Role for ECS Task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.app_name}-${var.environment}-ECS-task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_main_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_s3_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

data "aws_iam_policy_document" "task_write_s3_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.app_name}-${var.environment}-assets-bucket",
      "arn:aws:s3:::${var.app_name}-${var.environment}-assets-bucket/*"
    ]
  }
}

resource "aws_iam_policy" "task_write_s3_policy" {
  name   = "${var.app_name}-${var.environment}-assets-s3_rw_policy"
  policy = data.aws_iam_policy_document.task_write_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3_access" {
  role       = aws_iam_role.ecs_task_iam_role.name
  policy_arn = aws_iam_policy.task_write_s3_policy.arn
}

resource "aws_iam_role" "ecs_task_iam_role" {
  name               = "${var.app_name}-${var.environment}-ECS_task-iam_role"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

## IAM role for SMS event destination

resource "aws_iam_policy" "sms_cloudwatch_dest_policy" {
  name        = "${var.app_name}-${var.environment}-cloudwatch_dest-policy"
  description = "Policy to send SMS event to cloud watch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.sms_messaging_log_group.arn}"
      }
    ]
  })
}

resource "aws_iam_role" "sms_cloudwatch_role" {
  name = "${var.app_name}-${var.environment}-SMS-cloudwatch-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sms-voice.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sms_cloudwatch_role_dest_policy" {
  role       = aws_iam_role.sms_cloudwatch_role.name
  policy_arn = aws_iam_policy.sms_cloudwatch_dest_policy.arn
}

## IAM user for SDK

resource "aws_iam_user" "local_developer" {
  name = "${var.app_name}-${var.environment}-local_developer"

  tags = {
    Environment = var.environment
  }
}

# resource "aws_iam_access_key" "local_developer" {
#   user = aws_iam_user.local_developer.name
# }
