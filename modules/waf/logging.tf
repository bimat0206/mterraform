# -----------------------------------------------------------------------------
# CloudWatch Log Group for WAF Logs
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "waf" {
  count = var.enable_logging && var.log_destination_type == "cloudwatch" ? 1 : 0

  name              = local.log_group_name
  retention_in_days = var.log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-waf-logs"
    }
  )
}

# -----------------------------------------------------------------------------
# CloudWatch Log Resource Policy for WAF
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_resource_policy" "waf" {
  count = var.enable_logging && var.log_destination_type == "cloudwatch" ? 1 : 0

  policy_name = "${local.name}-waf-logging-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "wafv2.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.waf[0].arn}:*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:${data.aws_partition.current.partition}:wafv2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*"
          }
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# WAF Logging Configuration
# -----------------------------------------------------------------------------
resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.enable_logging ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = [local.log_destination_arn]

  # Redacted fields for privacy/compliance
  dynamic "redacted_fields" {
    for_each = var.redacted_fields
    content {
      dynamic "method" {
        for_each = redacted_fields.value.method ? [1] : []
        content {}
      }

      dynamic "query_string" {
        for_each = redacted_fields.value.query_string ? [1] : []
        content {}
      }

      dynamic "uri_path" {
        for_each = redacted_fields.value.uri_path ? [1] : []
        content {}
      }

      dynamic "single_header" {
        for_each = redacted_fields.value.single_header != "" ? [1] : []
        content {
          name = redacted_fields.value.single_header
        }
      }
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.waf,
    aws_cloudwatch_log_resource_policy.waf
  ]
}
