# -----------------------------------------------------------------------------
# Product Integrations
# -----------------------------------------------------------------------------
resource "aws_securityhub_product_subscription" "this" {
  for_each = var.enable_security_hub && var.enable_product_integrations ? toset(local.default_product_arns) : []

  product_arn = each.value

  depends_on = [aws_securityhub_account.this]

  # Ignore errors if product is not available in the region
  lifecycle {
    ignore_changes = []
  }
}
