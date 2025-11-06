# ECR Repositories
resource "aws_ecr_repository" "this" {
  for_each = var.repositories

  name                 = "${local.name_prefix}-${each.key}"
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete

  # Image scanning configuration
  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  # Encryption configuration
  encryption_configuration {
    encryption_type = each.value.encryption_type
    kms_key         = each.value.kms_key_arn
  }

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name       = "${local.name_prefix}-${each.key}"
      Repository = each.key
    }
  )
}

# Repository Policies
resource "aws_ecr_repository_policy" "this" {
  for_each = {
    for k, v in var.repositories : k => v
    if v.repository_policy != null
  }

  repository = aws_ecr_repository.this[each.key].name
  policy     = each.value.repository_policy
}

# Lifecycle Policies
resource "aws_ecr_lifecycle_policy" "this" {
  for_each = var.repositories

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = concat(
      # Rule 1: Keep protected tagged images indefinitely
      length(each.value.lifecycle_policy.protected_tags) > 0 ? [{
        rulePriority = 1
        description  = "Keep protected tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = each.value.lifecycle_policy.protected_tags
          countType     = "imageCountMoreThan"
          countNumber   = 999999
        }
        action = {
          type = "expire"
        }
      }] : [],

      # Rule 2: Expire old tagged images
      [{
        rulePriority = 2
        description  = "Expire tagged images older than ${each.value.lifecycle_policy.max_tagged_days} days"
        selection = {
          tagStatus   = "tagged"
          tagPrefixList = ["v"]
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = each.value.lifecycle_policy.max_tagged_days
        }
        action = {
          type = "expire"
        }
      }],

      # Rule 3: Keep only N most recent images
      [{
        rulePriority = 3
        description  = "Keep only ${each.value.lifecycle_policy.max_image_count} most recent images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = each.value.lifecycle_policy.max_image_count
        }
        action = {
          type = "expire"
        }
      }],

      # Rule 4: Expire untagged images
      each.value.lifecycle_policy.enable_untagged_expiry ? [{
        rulePriority = 4
        description  = "Expire untagged images older than ${each.value.lifecycle_policy.max_untagged_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = each.value.lifecycle_policy.max_untagged_days
        }
        action = {
          type = "expire"
        }
      }] : []
    )
  })
}

# Registry Scanning Configuration
resource "aws_ecr_registry_scanning_configuration" "this" {
  count = var.enable_enhanced_scanning ? 1 : 0

  scan_type = "ENHANCED"

  rule {
    scan_frequency = var.scan_frequency

    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}

# Registry Replication Configuration
resource "aws_ecr_replication_configuration" "this" {
  count = var.enable_replication && length(var.replication_configuration.rules) > 0 ? 1 : 0

  replication_configuration {
    dynamic "rule" {
      for_each = var.replication_configuration.rules

      content {
        dynamic "destination" {
          for_each = rule.value.destinations

          content {
            region      = destination.value.region
            registry_id = destination.value.registry_id
          }
        }

        dynamic "repository_filter" {
          for_each = rule.value.repository_filters

          content {
            filter      = repository_filter.value.filter
            filter_type = repository_filter.value.filter_type
          }
        }
      }
    }
  }
}

# Pull Through Cache Rules
resource "aws_ecr_pull_through_cache_rule" "this" {
  for_each = var.enable_pull_through_cache ? var.pull_through_cache_rules : {}

  ecr_repository_prefix = each.key
  upstream_registry_url = each.value.upstream_registry_url
  credential_arn        = each.value.credential_arn
}
