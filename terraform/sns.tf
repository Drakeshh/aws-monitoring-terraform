# SNS topic for eu-west-3 alarms (Lambda, API Gateway, DynamoDB, canary)
resource "aws_sns_topic" "alerts" {
  name = "portfolio-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# SNS topic for us-east-1 alarms (CloudFront, billing)
resource "aws_sns_topic" "alerts_us_east_1" {
  provider = aws.us_east_1
  name     = "portfolio-alerts-billing"
}

resource "aws_sns_topic_subscription" "email_us_east_1" {
  provider  = aws.us_east_1
  topic_arn = aws_sns_topic.alerts_us_east_1.arn
  protocol  = "email"
  endpoint  = var.alert_email
}