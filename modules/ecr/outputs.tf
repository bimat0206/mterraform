# Repository Outputs
output "repository_arns" {
  description = "Map of repository names to ARNs"
  value       = { for k, v in aws_ecr_repository.this : k => v.arn }
}

output "repository_urls" {
  description = "Map of repository names to URLs"
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}

output "repository_registry_ids" {
  description = "Map of repository names to registry IDs"
  value       = { for k, v in aws_ecr_repository.this : k => v.registry_id }
}

output "repository_names" {
  description = "Map of repository keys to full repository names"
  value       = { for k, v in aws_ecr_repository.this : k => v.name }
}

# Registry Information
output "registry_id" {
  description = "The registry ID where the repositories are located"
  value       = local.account_id
}

output "registry_url" {
  description = "The URL of the ECR registry"
  value       = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}

# Enhanced Scanning
output "enhanced_scanning_enabled" {
  description = "Whether enhanced scanning is enabled"
  value       = var.enable_enhanced_scanning
}

output "scan_frequency" {
  description = "The scan frequency for enhanced scanning"
  value       = var.enable_enhanced_scanning ? var.scan_frequency : null
}

# Replication
output "replication_enabled" {
  description = "Whether replication is enabled"
  value       = var.enable_replication && length(var.replication_configuration.rules) > 0
}

output "replication_destinations" {
  description = "List of replication destinations"
  value = var.enable_replication && length(var.replication_configuration.rules) > 0 ? flatten([
    for rule in var.replication_configuration.rules : [
      for dest in rule.destinations : {
        region      = dest.region
        registry_id = dest.registry_id
      }
    ]
  ]) : []
}

# Pull Through Cache
output "pull_through_cache_enabled" {
  description = "Whether pull through cache is enabled"
  value       = var.enable_pull_through_cache
}

output "pull_through_cache_rules" {
  description = "Map of pull through cache rules"
  value = var.enable_pull_through_cache ? {
    for k, v in aws_ecr_pull_through_cache_rule.this : k => {
      upstream_registry_url = v.upstream_registry_url
      registry_id           = v.registry_id
    }
  } : {}
}

# Docker Commands
output "docker_login_command" {
  description = "Command to authenticate Docker to ECR"
  value       = "aws ecr get-login-password --region ${local.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}

output "docker_commands" {
  description = "Common Docker commands for ECR repositories"
  value = {
    for k, v in aws_ecr_repository.this : k => {
      login = "aws ecr get-login-password --region ${local.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
      build = "docker build -t ${v.repository_url}:latest ."
      tag   = "docker tag ${each.key}:latest ${v.repository_url}:latest"
      push  = "docker push ${v.repository_url}:latest"
      pull  = "docker pull ${v.repository_url}:latest"
    }
  }
}

# Repository Count
output "repository_count" {
  description = "Total number of repositories created"
  value       = length(aws_ecr_repository.this)
}

# Summary
output "summary" {
  description = "Summary of ECR configuration"
  value = {
    repository_count          = length(aws_ecr_repository.this)
    enhanced_scanning_enabled = var.enable_enhanced_scanning
    replication_enabled       = var.enable_replication && length(var.replication_configuration.rules) > 0
    pull_through_cache_enabled = var.enable_pull_through_cache
    registry_url              = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
    repositories = {
      for k, v in aws_ecr_repository.this : k => {
        name                 = v.name
        url                  = v.repository_url
        image_tag_mutability = v.image_tag_mutability
        scan_on_push         = v.image_scanning_configuration[0].scan_on_push
        encryption_type      = v.encryption_configuration[0].encryption_type
      }
    }
  }
}
