# -----------------------------------------------------------------------------
# SNS Topic for Config Notifications
# -----------------------------------------------------------------------------
resource "aws_sns_topic" "config" {
  count = var.create_sns_topic ? 1 : 0

  name              = local.sns_topic_name
  display_name      = "AWS Config Notifications"
  kms_master_key_id = "alias/aws/sns"

  tags = merge(
    local.common_tags,
    {
      Name = local.sns_topic_name
    }
  )
}

resource "aws_sns_topic_policy" "config" {
  count = var.create_sns_topic ? 1 : 0

  arn = aws_sns_topic.config[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigSNSPolicy"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.config[0].arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "config_email" {
  for_each = var.create_sns_topic ? toset(var.sns_email_subscriptions) : []

  topic_arn = aws_sns_topic.config[0].arn
  protocol  = "email"
  endpoint  = each.value
}
