# -----------------------------------------------------------------------------
# SNS Topic for GuardDuty Findings
# -----------------------------------------------------------------------------
resource "aws_sns_topic" "findings" {
  count = var.enable_guardduty && var.enable_sns_notifications ? 1 : 0

  name              = local.sns_topic_name
  display_name      = "GuardDuty Findings"
  kms_master_key_id = "alias/aws/sns"

  tags = merge(
    local.common_tags,
    {
      Name = local.sns_topic_name
    }
  )
}

resource "aws_sns_topic_policy" "findings" {
  count = var.enable_guardduty && var.enable_sns_notifications ? 1 : 0

  arn = aws_sns_topic.findings[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchEventsToPublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.findings[0].arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "findings_email" {
  for_each = var.enable_guardduty && var.enable_sns_notifications ? toset(var.sns_email_subscriptions) : []

  topic_arn = aws_sns_topic.findings[0].arn
  protocol  = "email"
  endpoint  = each.value
}

# -----------------------------------------------------------------------------
# CloudWatch Event Rule for GuardDuty Findings
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  count = var.enable_guardduty && var.enable_cloudwatch_events ? 1 : 0

  name        = "${local.name_prefix}-findings"
  description = "Capture GuardDuty findings with severity ${min(var.finding_severity_filter...)} and above"

  event_pattern = jsonencode(local.event_pattern)

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-findings"
    }
  )
}

resource "aws_cloudwatch_event_target" "sns" {
  count = var.enable_guardduty && var.enable_cloudwatch_events && var.enable_sns_notifications ? 1 : 0

  rule      = aws_cloudwatch_event_rule.guardduty_findings[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.findings[0].arn

  input_transformer {
    input_paths = {
      severity    = "$.detail.severity"
      title       = "$.detail.title"
      description = "$.detail.description"
      region      = "$.region"
      account     = "$.account"
      time        = "$.time"
      type        = "$.detail.type"
    }

    input_template = <<TEMPLATE
"AWS GuardDuty Finding - Severity <severity>"
"Title: <title>"
"Description: <description>"
"Finding Type: <type>"
"Account: <account>"
"Region: <region>"
"Time: <time>"
"View in Console: https://<region>.console.aws.amazon.com/guardduty/home?region=<region>#/findings"
TEMPLATE
  }
}
