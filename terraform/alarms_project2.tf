# ===========================================================
# Lambda alarms
# ===========================================================

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "project2-lambda-errors"
  alarm_description   = "Lambda function produced an error (uncaught exception)"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = data.aws_lambda_function.incident_handler.function_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "project2-lambda-throttles"
  alarm_description   = "Lambda function is being throttled (concurrency limit hit)"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = data.aws_lambda_function.incident_handler.function_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "project2-lambda-duration-high"
  alarm_description   = "Lambda p99 duration approaching timeout (leading indicator)"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  extended_statistic  = "p99"
  threshold           = 3000
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = data.aws_lambda_function.incident_handler.function_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

# ===========================================================
# API Gateway alarms
# ===========================================================

resource "aws_cloudwatch_metric_alarm" "apigw_5xx" {
  alarm_name          = "project2-apigw-5xx-errors"
  alarm_description   = "API Gateway returning 5xx errors (integration or backend failure)"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = var.api_gateway_name
    Stage   = var.api_gateway_stage
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "apigw_4xx" {
  alarm_name          = "project2-apigw-4xx-elevated"
  alarm_description   = "API Gateway 4xx spike (potential abuse, broken client, or scanning)"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = var.api_gateway_name
    Stage   = var.api_gateway_stage
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

# ===========================================================
# DynamoDB alarms
# ===========================================================

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  alarm_name          = "project2-dynamodb-throttles"
  alarm_description   = "DynamoDB table is throttling requests"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = data.aws_dynamodb_table.incidents.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}