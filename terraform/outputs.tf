output "sns_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "ARN of the alerts SNS topic (eu-west-3 — Lambda, API GW, DynamoDB, canary)"
}

output "sns_topic_arn_us_east_1" {
  value       = aws_sns_topic.alerts_us_east_1.arn
  description = "ARN of the alerts SNS topic (us-east-1 — CloudFront, billing)"
}

output "dashboard_url" {
  value       = "https://eu-west-3.console.aws.amazon.com/cloudwatch/home?region=eu-west-3#dashboards:name=${aws_cloudwatch_dashboard.portfolio.dashboard_name}"
  description = "CloudWatch dashboard URL — open this to see the monitoring overview"
}

output "canary_name" {
  value       = aws_synthetics_canary.static_site.name
  description = "Name of the Synthetics canary monitoring the static site"
}

output "canary_artifacts_bucket" {
  value       = aws_s3_bucket.canary_artifacts.bucket
  description = "S3 bucket storing canary screenshots, HAR files, and logs"
}

output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "ARN of the IAM role assumed by GitHub Actions via OIDC"
}