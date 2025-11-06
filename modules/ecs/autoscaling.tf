# Auto-scaling Targets
resource "aws_appautoscaling_target" "this" {
  for_each = {
    for k, v in var.services : k => v
    if v.autoscaling != null
  }

  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = each.value.autoscaling.min_capacity
  max_capacity       = each.value.autoscaling.max_capacity
}

# Target Tracking Scaling Policies
resource "aws_appautoscaling_policy" "target_tracking" {
  for_each = {
    for pair in flatten([
      for svc_key, svc in var.services : [
        for idx, policy in(svc.autoscaling != null && svc.autoscaling.target_tracking_policies != null ? svc.autoscaling.target_tracking_policies : []) : {
          key        = "${svc_key}-${policy.name}"
          svc_key    = svc_key
          policy     = policy
        }
      ]
    ]) : pair.key => pair
  }

  name               = each.value.policy.name
  service_namespace  = aws_appautoscaling_target.this[each.value.svc_key].service_namespace
  resource_id        = aws_appautoscaling_target.this[each.value.svc_key].resource_id
  scalable_dimension = aws_appautoscaling_target.this[each.value.svc_key].scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = each.value.policy.target_value
    scale_in_cooldown  = each.value.policy.scale_in_cooldown
    scale_out_cooldown = each.value.policy.scale_out_cooldown

    # Predefined metric
    dynamic "predefined_metric_specification" {
      for_each = each.value.policy.predefined_metric != null ? [1] : []
      content {
        predefined_metric_type = each.value.policy.predefined_metric
      }
    }

    # Custom metric
    dynamic "customized_metric_specification" {
      for_each = each.value.policy.custom_metric != null ? [1] : []
      content {
        metric_name = each.value.policy.custom_metric.metric_name
        namespace   = each.value.policy.custom_metric.namespace
        statistic   = each.value.policy.custom_metric.statistic
      }
    }
  }
}

# Step Scaling Policies
resource "aws_appautoscaling_policy" "step_scaling" {
  for_each = {
    for pair in flatten([
      for svc_key, svc in var.services : [
        for idx, policy in(svc.autoscaling != null && svc.autoscaling.step_scaling_policies != null ? svc.autoscaling.step_scaling_policies : []) : {
          key        = "${svc_key}-${policy.name}"
          svc_key    = svc_key
          policy     = policy
        }
      ]
    ]) : pair.key => pair
  }

  name               = each.value.policy.name
  service_namespace  = aws_appautoscaling_target.this[each.value.svc_key].service_namespace
  resource_id        = aws_appautoscaling_target.this[each.value.svc_key].resource_id
  scalable_dimension = aws_appautoscaling_target.this[each.value.svc_key].scalable_dimension
  policy_type        = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = each.value.policy.adjustment_type
    cooldown                = each.value.policy.cooldown
    metric_aggregation_type = each.value.policy.metric_aggregation_type

    dynamic "step_adjustment" {
      for_each = each.value.policy.step_adjustments
      content {
        scaling_adjustment          = step_adjustment.value.scaling_adjustment
        metric_interval_lower_bound = step_adjustment.value.metric_interval_lower_bound
        metric_interval_upper_bound = step_adjustment.value.metric_interval_upper_bound
      }
    }
  }
}
