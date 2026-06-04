# Account-wide billing alarm
# Note: AWS/Billing metrics only publish to us-east-1, regardless of resource location.
# This is the safety net that enforces this project's $0/month commitment.
resource "aws_cloudwatch_metric_alarm" "billing" {
  provider = aws.us_east_1

  alarm_name          = "billing-alarm-${var.billing_alarm_threshold_usd}usd"
  alarm_description   = "Estimated AWS charges exceeded $${var.billing_alarm_threshold_usd} USD"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600
  statistic           = "Maximum"
  threshold           = var.billing_alarm_threshold_usd
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [aws_sns_topic.alerts_us_east_1.arn]
}