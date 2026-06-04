# Lambda function from Project 2
data "aws_lambda_function" "incident_handler" {
  function_name = var.lambda_function_name
}

# DynamoDB table from Project 2
data "aws_dynamodb_table" "incidents" {
  name = var.dynamodb_table_name
}

# CloudWatch log group auto-created by Lambda from Project 2
data "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${var.lambda_function_name}"
}

# Current AWS account ID (used for globally-unique S3 bucket naming)
data "aws_caller_identity" "current" {}