# -----------------------------------------------------------------------------
# IP Sets
# -----------------------------------------------------------------------------
resource "aws_wafv2_ip_set" "allowlist" {
  count = length(var.ip_allowlist) > 0 ? 1 : 0

  name               = "${local.name}-ip-allowlist"
  description        = "IP allowlist for ${local.name}"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.ip_allowlist

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-ip-allowlist"
    }
  )
}

resource "aws_wafv2_ip_set" "blocklist" {
  count = length(var.ip_blocklist) > 0 ? 1 : 0

  name               = "${local.name}-ip-blocklist"
  description        = "IP blocklist for ${local.name}"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.ip_blocklist

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-ip-blocklist"
    }
  )
}
