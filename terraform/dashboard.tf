resource "aws_cloudwatch_dashboard" "portfolio" {
  dashboard_name = "portfolio-overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = "# Portfolio Monitoring Dashboard\n**Project 1** (Static Site) · **Project 2** (Incident API) — eu-west-3 / Global"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6
        properties = {
          title  = "Project 1 — CloudFront Requests & Errors"
          region = "us-east-1"
          metrics = [
            ["AWS/CloudFront", "Requests", "DistributionId", var.cloudfront_distribution_id, "Region", "Global"],
            [".", "4xxErrorRate", ".", ".", ".", ".", { yAxis = "right" }],
            [".", "5xxErrorRate", ".", ".", ".", ".", { yAxis = "right" }]
          ]
          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 6
        properties = {
          title  = "Project 1 — CloudFront Cache Hit Rate"
          region = "us-east-1"
          metrics = [
            ["AWS/CloudFront", "CacheHitRate", "DistributionId", var.cloudfront_distribution_id, "Region", "Global"]
          ]
          period = 300
          stat   = "Average"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 12
        height = 6
        properties = {
          title  = "Project 2 — Lambda Invocations / Errors / Throttles"
          region = "eu-west-3"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_name],
            [".", "Errors", ".", "."],
            [".", "Throttles", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 8
        width  = 12
        height = 6
        properties = {
          title  = "Project 2 — Lambda Duration (p50 / p99)"
          region = "eu-west-3"
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", var.lambda_function_name, { stat = "p50" }],
            ["...", { stat = "p99" }]
          ]
          period = 300
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 14
        width  = 12
        height = 6
        properties = {
          title  = "Project 2 — API Gateway 4xx / 5xx"
          region = "eu-west-3"
          metrics = [
            ["AWS/ApiGateway", "4XXError", "ApiName", var.api_gateway_name, "Stage", var.api_gateway_stage],
            [".", "5XXError", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 14
        width  = 12
        height = 6
        properties = {
          title  = "Project 2 — DynamoDB Capacity"
          region = "eu-west-3"
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", var.dynamodb_table_name],
            [".", "ConsumedWriteCapacityUnits", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 20
        width  = 24
        height = 6
        properties = {
          title  = "Project 1 — Synthetic Canary Success %"
          region = "eu-west-3"
          metrics = [
            ["CloudWatchSynthetics", "SuccessPercent", "CanaryName", "static-site-heartbeat"]
          ]
          period = 21600
          stat   = "Average"
          view   = "timeSeries"
        }
      }
    ]
  })
}