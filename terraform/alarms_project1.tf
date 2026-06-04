# CloudFront 5xx error rate alarm
# Note: CloudFront metrics only publish to us-east-1, so this alarm and its SNS target live there
resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx" {
  provider = aws.us_east_1

  alarm_name          = "project1-cloudfront-5xx-errors"
  alarm_description   = "CloudFront returning 5xx errors for the static site"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = var.cloudfront_distribution_id
    Region         = "Global"
  }

  alarm_actions = [aws_sns_topic.alerts_us_east_1.arn]
  ok_actions    = [aws_sns_topic.alerts_us_east_1.arn]
}