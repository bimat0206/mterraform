# -----------------------------------------------------------------------------
# AWS Config Managed Rules
# -----------------------------------------------------------------------------
resource "aws_config_config_rule" "managed" {
  for_each = var.enable_managed_rules ? { for k, v in var.managed_rules : k => v if v.enabled } : {}

  name        = "${local.name_prefix}-${each.key}"
  description = each.value.description

  source {
    owner             = "AWS"
    source_identifier = each.value.identifier
  }

  input_parameters = length(each.value.input_parameters) > 0 ? jsonencode(each.value.input_parameters) : null

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${each.key}"
    }
  )

  depends_on = [
    aws_config_configuration_recorder.this,
    aws_config_delivery_channel.this
  ]
}
