locals {
  # Create a consistent VPN name using prefix and name
  vpn_name = "${var.name_prefix}${var.name_prefix != "" ? "-" : ""}${var.name}"
  
  # Create a consistent Customer Gateway name using prefix and name
  cgw_name = var.customer_gateway_name != null ? "${var.name_prefix}${var.name_prefix != "" ? "-" : ""}${var.customer_gateway_name}" : "${local.vpn_name}-cgw"
  
  # Use the vpn_name for tagging
  vpn_tags = merge(var.tags, {
    Name = local.vpn_name
  })
}

resource "aws_customer_gateway" "this" {
  bgp_asn    = var.customer_gateway_bgp_asn
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1" # Standard type for Site-to-Site VPN

  tags = merge(local.vpn_tags, {
    Name = local.cgw_name
  })

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "aws_vpn_connection" "this" {
  customer_gateway_id = aws_customer_gateway.this.id
  transit_gateway_id  = var.transit_gateway_id
  type               = "ipsec.1"
  static_routes_only = var.static_routes_only

  # Tunnel 1 configuration
  tunnel1_inside_cidr = var.inside_ip_cidr_tunnel1
  tunnel1_preshared_key = var.preshared_key_tunnel1
  
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms = ["SHA2-256"]
  tunnel1_phase1_dh_group_numbers = [14]
  tunnel1_phase1_lifetime_seconds = 28800
  
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase2_integrity_algorithms = ["SHA2-256"]
  tunnel1_phase2_dh_group_numbers = [14]
  tunnel1_phase2_lifetime_seconds = 3600
  
  tunnel1_ike_versions = ["ikev2"]
  tunnel1_dpd_timeout_action = "clear"
  tunnel1_startup_action = "add"


  # Tunnel 2 configuration
  tunnel2_inside_cidr = var.inside_ip_cidr_tunnel2
  tunnel2_preshared_key = var.preshared_key_tunnel2
  
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase1_integrity_algorithms = ["SHA2-256"]
  tunnel2_phase1_dh_group_numbers = [14]
  tunnel2_phase1_lifetime_seconds = 28800
  
  tunnel2_phase2_encryption_algorithms = ["AES256"]
  tunnel2_phase2_integrity_algorithms = ["SHA2-256"]
  tunnel2_phase2_dh_group_numbers = [14]
  tunnel2_phase2_lifetime_seconds = 3600
  
  tunnel2_ike_versions = ["ikev2"]
  tunnel2_dpd_timeout_action = "clear"
  tunnel2_startup_action = "add"


  local_ipv4_network_cidr = "0.0.0.0/0"
  remote_ipv4_network_cidr = "0.0.0.0/0"
  # Enable CloudWatch logging for both tunnels
  tunnel1_enable_tunnel_lifecycle_control = true
  tunnel1_log_options {
    cloudwatch_log_options {
      log_enabled = true
      log_group_arn = aws_cloudwatch_log_group.tunnel1.arn
      log_output_format = "json"
    }
  }

  tunnel2_enable_tunnel_lifecycle_control = true
  tunnel2_log_options {
    cloudwatch_log_options {
      log_enabled = true
      log_group_arn = aws_cloudwatch_log_group.tunnel2.arn
      log_output_format = "json"
    }
  }
  tags = merge(local.vpn_tags, {
    Name = "${local.vpn_name}"
  })

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

