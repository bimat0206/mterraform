# Cluster Outputs
output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "capacity_providers" {
  description = "Capacity providers enabled for the cluster"
  value       = local.capacity_providers
}

# Task Definition Outputs
output "task_definition_arns" {
  description = "Map of task definition keys to ARNs"
  value       = { for k, v in aws_ecs_task_definition.this : k => v.arn }
}

output "task_definition_families" {
  description = "Map of task definition keys to family names"
  value       = { for k, v in aws_ecs_task_definition.this : k => v.family }
}

output "task_definition_revisions" {
  description = "Map of task definition keys to revisions"
  value       = { for k, v in aws_ecs_task_definition.this : k => v.revision }
}

# Service Outputs
output "service_ids" {
  description = "Map of service keys to IDs"
  value       = { for k, v in aws_ecs_service.this : k => v.id }
}

output "service_names" {
  description = "Map of service keys to names"
  value       = { for k, v in aws_ecs_service.this : k => v.name }
}

output "service_cluster_arns" {
  description = "Map of service keys to cluster ARNs"
  value       = { for k, v in aws_ecs_service.this : k => v.cluster }
}

output "service_desired_counts" {
  description = "Map of service keys to desired counts"
  value       = { for k, v in aws_ecs_service.this : k => v.desired_count }
}

# IAM Role Outputs
output "task_execution_role_arn" {
  description = "ARN of the task execution role"
  value       = var.create_task_execution_role ? aws_iam_role.task_execution[0].arn : null
}

output "task_execution_role_name" {
  description = "Name of the task execution role"
  value       = var.create_task_execution_role ? aws_iam_role.task_execution[0].name : null
}

output "task_role_arns" {
  description = "Map of task definition keys to task role ARNs"
  value       = { for k, v in aws_iam_role.task_role : k => v.arn }
}

output "task_role_names" {
  description = "Map of task definition keys to task role names"
  value       = { for k, v in aws_iam_role.task_role : k => v.name }
}

# CloudWatch Log Group Outputs
output "log_group_names" {
  description = "Map of task definition keys to CloudWatch log group names"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

output "log_group_arns" {
  description = "Map of task definition keys to CloudWatch log group ARNs"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
}

# Auto-scaling Outputs
output "autoscaling_target_ids" {
  description = "Map of service keys to autoscaling target IDs"
  value       = { for k, v in aws_appautoscaling_target.this : k => v.id }
}

output "autoscaling_enabled" {
  description = "Map of service keys to autoscaling enabled status"
  value = {
    for k, v in var.services : k => v.autoscaling != null
  }
}

# Container Insights
output "container_insights_enabled" {
  description = "Whether Container Insights is enabled"
  value       = var.enable_container_insights
}

# Summary
output "summary" {
  description = "Summary of ECS cluster configuration"
  value = {
    cluster_name           = aws_ecs_cluster.this.name
    cluster_arn            = aws_ecs_cluster.this.arn
    capacity_providers     = local.capacity_providers
    container_insights     = var.enable_container_insights
    task_definition_count  = length(aws_ecs_task_definition.this)
    service_count          = length(aws_ecs_service.this)
    log_retention_days     = var.log_retention_in_days

    task_definitions = {
      for k, v in aws_ecs_task_definition.this : k => {
        family   = v.family
        revision = v.revision
        cpu      = v.cpu
        memory   = v.memory
      }
    }

    services = {
      for k, v in aws_ecs_service.this : k => {
        name                 = v.name
        desired_count        = v.desired_count
        launch_type          = v.launch_type
        autoscaling_enabled  = var.services[k].autoscaling != null
      }
    }
  }
}

# Commands
output "commands" {
  description = "Useful ECS commands"
  value = {
    list_services      = "aws ecs list-services --cluster ${aws_ecs_cluster.this.name}"
    list_tasks         = "aws ecs list-tasks --cluster ${aws_ecs_cluster.this.name}"
    describe_cluster   = "aws ecs describe-clusters --clusters ${aws_ecs_cluster.this.name}"
    view_logs_command  = "aws logs tail ${local.log_group_prefix}/<task-key> --follow"
    update_service     = "aws ecs update-service --cluster ${aws_ecs_cluster.this.name} --service <service-name> --force-new-deployment"
    execute_command    = "aws ecs execute-command --cluster ${aws_ecs_cluster.this.name} --task <task-id> --container <container-name> --interactive --command '/bin/sh'"
  }
}

# Service URLs (if using ALB)
output "service_info" {
  description = "Service information including task definitions and configurations"
  value = {
    for k, v in var.services : k => {
      service_name        = aws_ecs_service.this[k].name
      task_definition     = aws_ecs_task_definition.this[v.task_definition_key].family
      desired_count       = v.desired_count
      has_load_balancer   = length(v.load_balancers) > 0
      autoscaling_enabled = v.autoscaling != null
      autoscaling_config  = v.autoscaling != null ? {
        min_capacity = v.autoscaling.min_capacity
        max_capacity = v.autoscaling.max_capacity
      } : null
    }
  }
}
