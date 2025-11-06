# Additional locals that don't need to be in main.tf can be placed here
# This helps with organization and clarity

locals {

  create_access_logs_bucket = local.access_logs_enabled && length(var.access_logs_bucket) == 0

  create_connection_logs_bucket = local.connection_logs_enabled && length(var.connection_logs_bucket) == 0

  # Forward facing name of the ALB
  alb_name_normalized = replace(lower(local.alb_name), "_", "-")

  # Target group mapping with useful metadata
  target_groups_info = {
    for tg in var.target_groups : tg.name => {
      port              = tg.port
      protocol          = tg.protocol
      target_type       = tg.target_type
      health_check_path = lookup(lookup(tg, "health_check", {}), "path", "/")
      health_check_port = lookup(lookup(tg, "health_check", {}), "port", "traffic-port")
    }
  }

  # HTTP and HTTPS listener normalizations have been removed as requested
}
