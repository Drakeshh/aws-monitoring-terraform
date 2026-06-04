# S3 bucket for canary artifacts (screenshots, HAR files, logs)
resource "aws_s3_bucket" "canary_artifacts" {
  bucket        = "synthetics-canary-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "canary_artifacts" {
  bucket                  = aws_s3_bucket.canary_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle: delete artifacts older than 30 days to bound storage costs
resource "aws_s3_bucket_lifecycle_configuration" "canary_artifacts" {
  bucket = aws_s3_bucket.canary_artifacts.id

  rule {
    id     = "delete-old-artifacts"
    status = "Enabled"
    filter {}
    expiration {
      days = 30
    }
  }
}

# IAM role for the canary (runs as Lambda under the hood)
resource "aws_iam_role" "canary" {
  name = "synthetics-canary-static-site-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "canary" {
  name = "synthetics-canary-policy"
  role = aws_iam_role.canary.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetBucketLocation"
        ]
        Resource = "${aws_s3_bucket.canary_artifacts.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListAllMyBuckets"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = "cloudwatch:PutMetricData"
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "CloudWatchSynthetics"
          }
        }
      }
    ]
  })
}

# Zip the canary script (required path inside zip is nodejs/node_modules/<handler>.js)
data "archive_file" "canary_script" {
  type        = "zip"
  output_path = "${path.module}/canary.zip"

  source {
    content  = file("${path.module}/canary_script.js")
    filename = "nodejs/node_modules/heartbeat.js"
  }
}

# The canary itself
resource "aws_synthetics_canary" "static_site" {
  name                 = "static-site-heartbeat"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/canary-artifacts"
  execution_role_arn   = aws_iam_role.canary.arn
  handler              = "heartbeat.handler"
  zip_file             = data.archive_file.canary_script.output_path
  runtime_version      = "syn-nodejs-puppeteer-9.0"
  start_canary         = true

  schedule {
    expression = "cron(0 0,6,12,18 * * ? *)"
  }

  run_config {
    timeout_in_seconds = 60
    memory_in_mb       = 960
  }

  success_retention_period = 7
  failure_retention_period = 31
}

# Alarm on canary failure
resource "aws_cloudwatch_metric_alarm" "canary_failed" {
  alarm_name          = "project1-canary-failed"
  alarm_description   = "Synthetics canary for static site failed (likely site down or broken render)"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "SuccessPercent"
  namespace           = "CloudWatchSynthetics"
  period              = 3600
  statistic           = "Average"
  threshold           = 100
  treat_missing_data  = "notBreaching"

  dimensions = {
    CanaryName = aws_synthetics_canary.static_site.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}