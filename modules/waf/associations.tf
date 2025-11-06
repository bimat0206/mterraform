# -----------------------------------------------------------------------------
# Application Load Balancer Associations
# -----------------------------------------------------------------------------
resource "aws_wafv2_web_acl_association" "alb" {
  for_each = toset(var.associated_alb_arns)

  resource_arn = each.value
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# -----------------------------------------------------------------------------
# API Gateway Associations
# -----------------------------------------------------------------------------
resource "aws_wafv2_web_acl_association" "api_gateway" {
  for_each = toset(var.associated_api_gateway_arns)

  resource_arn = each.value
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# -----------------------------------------------------------------------------
# AppSync GraphQL API Associations
# -----------------------------------------------------------------------------
resource "aws_wafv2_web_acl_association" "appsync" {
  for_each = toset(var.associated_appsync_arns)

  resource_arn = each.value
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
