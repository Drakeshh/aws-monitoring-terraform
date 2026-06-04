# ============================================================
# GitHub Actions OIDC integration
# ============================================================
# Allows GitHub Actions workflows in this repo to assume a role
# in AWS without storing long-lived AWS credentials as secrets.
#
# How it works:
# 1. GitHub mints a short-lived JWT identifying the workflow run
# 2. AWS STS validates the JWT against this OIDC provider
# 3. If trust policy conditions match, returns temp credentials
# ============================================================

# Trust GitHub's OIDC token issuer
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Role assumed by GitHub Actions when running terraform
resource "aws_iam_role" "github_actions" {
  name = "github-actions-monitoring-deployer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # Locks this role to this specific repo
          "token.actions.githubusercontent.com:sub" = "repo:Drakeshh/aws-monitoring-terraform:*"
        }
      }
    }]
  })
}

# Attach the same custom policy your terraform-deployer user has
resource "aws_iam_role_policy_attachment" "github_actions_custom" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/terraform-deployer-custom-policy"
}

# Attach the monitoring-specific policy (SNS + Synthetics) we created today
resource "aws_iam_role_policy_attachment" "github_actions_monitoring" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/terraform-deployer-monitoring-policy"
}

# S3 access for Terraform state and canary artifacts
resource "aws_iam_role_policy_attachment" "github_actions_s3" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}