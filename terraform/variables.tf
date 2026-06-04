variable "project_name" {
  description = "Project name used for tagging resources created by this project"
  type        = string
  default     = "monitoring"
}

variable "environment" {
  description = "Environment name (used for tagging)"
  type        = string
  default     = "prod"
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alerts (required)"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for project1.sergipratmerin.com (required)"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name from Project 2 to monitor"
  type        = string
  default     = "incident-api-handler"
}

variable "api_gateway_name" {
  description = "API Gateway REST API name from Project 2 to monitor"
  type        = string
  default     = "incident-api-api"
}

variable "api_gateway_stage" {
  description = "API Gateway stage name from Project 2"
  type        = string
  default     = "prod"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name from Project 2 to monitor"
  type        = string
  default     = "incidents"
}

variable "billing_alarm_threshold_usd" {
  description = "Billing alarm threshold in USD (alerts when monthly estimated charges exceed this)"
  type        = number
  default     = 1
}