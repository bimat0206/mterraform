# -----------------------------------------------------------------------------
# SNS Topic for Security Hub Findings
# -----------------------------------------------------------------------------
resource "aws_sns_topic" "findings" {
  count = var.enable_security_hub && var.enable_sns_notifications ? 1 : 0

  name              = local.sns_topic_name
  display_name      = "Security Hub Findings"
  kms_master_key_id = "alias/aws/sns"

  tags = merge(
    local.common_tags,
    {
      Name = local.sns_topic_name
    }
  )
}

resource "aws_sns_topic_policy" "findings" {
  count = var.enable_security_hub && var.enable_sns_notifications ? 1 : 0

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
  for_each = var.enable_security_hub && var.enable_sns_notifications ? toset(var.sns_email_subscriptions) : []

  topic_arn = aws_sns_topic.findings[0].arn
  protocol  = "email"
  endpoint  = each.value
}

# -----------------------------------------------------------------------------
# CloudWatch Event Rule for Security Hub Findings
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "securityhub_findings" {
  count = var.enable_security_hub && var.enable_cloudwatch_events ? 1 : 0

  name        = "${local.name_prefix}-findings"
  description = "Capture Security Hub findings (${join(", ", var.finding_severity_filter)})"

  event_pattern = jsonencode(local.event_pattern)

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-findings"
    }
  )
}

resource "aws_cloudwatch_event_target" "sns" {
  count = var.enable_security_hub && var.enable_cloudwatch_events && var.enable_sns_notifications ? 1 : 0

  rule      = aws_cloudwatch_event_rule.securityhub_findings[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.findings[0].arn

  input_transformer {
    input_paths = {
      severity     = "$.detail.findings[0].Severity.Label"
      title        = "$.detail.findings[0].Title"
      description  = "$.detail.findings[0].Description"
      region       = "$.region"
      account      = "$.account"
      time         = "$.time"
      type         = "$.detail.findings[0].Types[0]"
      compliance   = "$.detail.findings[0].Compliance.Status"
      resource     = "$.detail.findings[0].Resources[0].Id"
      generator_id = "$.detail.findings[0].GeneratorId"
    }

    input_template = <<TEMPLATE
"AWS Security Hub Finding - <severity>"
"Title: <title>"
"Description: <description>"
"Finding Type: <type>"
"Compliance Status: <compliance>"
"Resource: <resource>"
"Generator: <generator_id>"
"Account: <account>"
"Region: <region>"
"Time: <time>"
"View in Console: https://<region>.console.aws.amazon.com/securityhub/home?region=<region>#/findings"
TEMPLATE
  }
}
