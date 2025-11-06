# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = local.cluster_name

  dynamic "setting" {
    for_each = var.cluster_settings
    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.cluster_name
    }
  )
}

# Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "this" {
  count = length(local.capacity_providers) > 0 ? 1 : 0

  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = local.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = default_capacity_provider_strategy.value.weight
      base              = default_capacity_provider_strategy.value.base
    }
  }
}
