# -----------------------------------------------------------------------------
# AWS Config Configuration Recorder
# -----------------------------------------------------------------------------
resource "aws_config_configuration_recorder" "this" {
  count = var.enable_config ? 1 : 0

  name     = local.name
  role_arn = var.create_iam_role ? aws_iam_role.config[0].arn : var.iam_role_arn

  recording_group {
    all_supported                 = var.all_supported_resource_types
    include_global_resource_types = var.include_global_resource_types
    resource_types                = var.all_supported_resource_types ? [] : var.resource_types
  }

  recording_mode {
    recording_frequency = var.recording_frequency
  }

  depends_on = [
    aws_iam_role_policy_attachment.config_policy,
    aws_iam_role_policy.config_s3,
    aws_iam_role_policy.config_sns
  ]
}

# -----------------------------------------------------------------------------
# AWS Config Delivery Channel
# -----------------------------------------------------------------------------
resource "aws_config_delivery_channel" "this" {
  count = var.enable_config ? 1 : 0

  name           = local.name
  s3_bucket_name = var.create_s3_bucket ? aws_s3_bucket.config[0].id : var.s3_bucket_name
  s3_key_prefix  = var.s3_key_prefix
  sns_topic_arn  = var.create_sns_topic ? aws_sns_topic.config[0].arn : null

  snapshot_delivery_properties {
    delivery_frequency = var.recording_frequency == "CONTINUOUS" ? "TwentyFour_Hours" : "TwentyFour_Hours"
  }

  depends_on = [
    aws_config_configuration_recorder.this,
    aws_s3_bucket_policy.config
  ]
}

# -----------------------------------------------------------------------------
# Start Configuration Recorder
# -----------------------------------------------------------------------------
resource "aws_config_configuration_recorder_status" "this" {
  count = var.enable_config ? 1 : 0

  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}
