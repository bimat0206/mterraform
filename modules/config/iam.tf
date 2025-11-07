# -----------------------------------------------------------------------------
# IAM Role for AWS Config
# -----------------------------------------------------------------------------
resource "aws_iam_role" "config" {
  count = var.create_iam_role ? 1 : 0

  name        = "${local.name_prefix}-role"
  description = "IAM role for AWS Config"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-role"
    }
  )
}

# Attach AWS managed policy for Config
resource "aws_iam_role_policy_attachment" "config_policy" {
  count = var.create_iam_role ? 1 : 0

  role       = aws_iam_role.config[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/ConfigRole"
}

# Custom policy for S3 bucket access
resource "aws_iam_role_policy" "config_s3" {
  count = var.create_iam_role && var.create_s3_bucket ? 1 : 0

  name = "${local.name_prefix}-s3-policy"
  role = aws_iam_role.config[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          aws_s3_bucket.config[0].arn,
          "${aws_s3_bucket.config[0].arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = "s3:GetBucketLocation"
        Resource = "*"
      }
    ]
  })
}

# Custom policy for SNS topic access
resource "aws_iam_role_policy" "config_sns" {
  count = var.create_iam_role && var.create_sns_topic ? 1 : 0

  name = "${local.name_prefix}-sns-policy"
  role = aws_iam_role.config[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.config[0].arn
      }
    ]
  })
}

# Policy for organization-wide access
resource "aws_iam_role_policy" "config_organization" {
  count = var.create_iam_role && var.enable_organization_aggregator ? 1 : 0

  name = "${local.name_prefix}-org-policy"
  role = aws_iam_role.config[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "organizations:ListAccounts",
          "organizations:DescribeOrganization",
          "organizations:ListAWSServiceAccessForOrganization"
        ]
        Resource = "*"
      }
    ]
  })
}
