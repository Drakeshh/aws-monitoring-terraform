# Log metric filter: count occurrences of the string "ERROR" in Lambda logs
# Catches caught exceptions and explicit logger.error() calls that don't
# surface in the standard AWS/Lambda Errors metric (which only counts uncaught exceptions).
resource "aws_cloudwatch_log_metric_filter" "lambda_errors" {
  name           = "lambda-error-string-count"
  log_group_name = data.aws_cloudwatch_log_group.lambda.name
  pattern        = "ERROR"

  metric_transformation {
    name          = "LambdaErrorStringCount"
    namespace     = "Portfolio/Lambda"
    value         = "1"
    default_value = "0"
  }
}

# Alarm on the custom metric
resource "aws_cloudwatch_metric_alarm" "lambda_error_string" {
  alarm_name          = "project2-lambda-error-string-detected"
  alarm_description   = "Lambda logs contain ERROR string (caught exception or explicit logger.error call)"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "LambdaErrorStringCount"
  namespace           = "Portfolio/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}