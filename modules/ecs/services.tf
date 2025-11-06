# ECS Services
resource "aws_ecs_service" "this" {
  for_each = var.services

  name            = "${local.cluster_name}-${each.key}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this[each.value.task_definition_key].arn
  desired_count   = each.value.desired_count

  # Launch type or capacity provider strategy
  launch_type = each.value.capacity_provider_strategy == null ? each.value.launch_type : null

  dynamic "capacity_provider_strategy" {
    for_each = each.value.capacity_provider_strategy != null ? each.value.capacity_provider_strategy : []
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = capacity_provider_strategy.value.base
    }
  }

  # Network configuration
  network_configuration {
    subnets          = each.value.subnets
    security_groups  = each.value.security_groups
    assign_public_ip = each.value.assign_public_ip
  }

  # Load balancer configuration
  dynamic "load_balancer" {
    for_each = each.value.load_balancers
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  # Service discovery
  dynamic "service_registries" {
    for_each = each.value.service_registry_arn != null ? [1] : []
    content {
      registry_arn = each.value.service_registry_arn
    }
  }

  # Deployment configuration
  deployment_minimum_healthy_percent = each.value.deployment_minimum_healthy_percent
  deployment_maximum_percent         = each.value.deployment_maximum_percent
  enable_ecs_managed_tags           = each.value.enable_ecs_managed_tags
  propagate_tags                    = each.value.propagate_tags
  enable_execute_command            = each.value.enable_execute_command
  health_check_grace_period_seconds = each.value.health_check_grace_period_seconds

  # Placement constraints
  dynamic "placement_constraints" {
    for_each = each.value.placement_constraints
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  # Ignore changes to desired_count when autoscaling is enabled
  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name       = "${local.cluster_name}-${each.key}"
      ServiceKey = each.key
    }
  )

  # Depend on load balancer listener rules (if any)
  depends_on = [
    aws_ecs_task_definition.this
  ]
}
