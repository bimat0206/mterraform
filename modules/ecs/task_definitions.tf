# Task Definitions
resource "aws_ecs_task_definition" "this" {
  for_each = var.task_definitions

  family                   = each.value.family != null ? each.value.family : "${local.cluster_name}-${each.key}"
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  network_mode             = each.value.network_mode
  requires_compatibilities = each.value.requires_compatibilities

  # Task role (application permissions)
  task_role_arn = (
    each.value.task_role_arn != null ? each.value.task_role_arn :
    (length(each.value.task_role_policies) > 0 || length(each.value.task_role_policy_statements) > 0) ? aws_iam_role.task_role[each.key].arn :
    null
  )

  # Execution role (ECS agent permissions)
  execution_role_arn = (
    each.value.execution_role_arn != null ? each.value.execution_role_arn :
    var.create_task_execution_role ? aws_iam_role.task_execution[0].arn :
    null
  )

  # Container definitions with CloudWatch logging
  container_definitions = jsonencode([
    for container in each.value.container_definitions : merge(
      {
        name         = container.name
        image        = container.image
        essential    = container.essential
        cpu          = container.cpu
        memory       = container.memory
        command      = container.command
        entryPoint   = container.entryPoint
        environment  = container.environment
        secrets      = container.secrets
        portMappings = container.portMappings
        healthCheck  = container.healthCheck
        mountPoints  = container.mountPoints
        volumesFrom  = container.volumesFrom
      },
      # Default CloudWatch logging if not specified
      {
        logConfiguration = container.logConfiguration != null ? container.logConfiguration : {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = var.create_cloudwatch_log_groups ? aws_cloudwatch_log_group.this[each.key].name : "${local.log_group_prefix}/${each.key}"
            "awslogs-region"        = local.region
            "awslogs-stream-prefix" = container.name
          }
        }
      }
    )
  ])

  # Volumes
  dynamic "volume" {
    for_each = each.value.volumes
    content {
      name      = volume.value.name
      host_path = volume.value.host_path

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port

          dynamic "authorization_config" {
            for_each = efs_volume_configuration.value.authorization_config != null ? [efs_volume_configuration.value.authorization_config] : []
            content {
              access_point_id = authorization_config.value.access_point_id
              iam             = authorization_config.value.iam
            }
          }
        }
      }
    }
  }

  # Runtime platform
  dynamic "runtime_platform" {
    for_each = each.value.runtime_platform != null ? [each.value.runtime_platform] : []
    content {
      operating_system_family = runtime_platform.value.operating_system_family
      cpu_architecture        = runtime_platform.value.cpu_architecture
    }
  }

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name       = each.value.family != null ? each.value.family : "${local.cluster_name}-${each.key}"
      TaskKey    = each.key
    }
  )
}
