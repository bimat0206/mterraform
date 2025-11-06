# AWS ECR (Elastic Container Registry) Terraform Module

This module creates and manages AWS ECR repositories with comprehensive lifecycle policies, image scanning, replication, and pull-through cache support.

## Features

- **Multiple Repositories**: Create and manage multiple ECR repositories
- **Lifecycle Policies**: Automatic image cleanup based on age and count
- **Image Scanning**: Basic and enhanced (AWS Inspector) scanning support
- **Encryption**: AES256 or KMS encryption for images at rest
- **Replication**: Cross-region and cross-account replication
- **Pull Through Cache**: Cache images from public registries (Docker Hub, GitHub, etc.)
- **Repository Policies**: Fine-grained access control
- **Image Tag Mutability**: Control whether image tags can be overwritten

## Usage

### Basic Configuration

```hcl
module "ecr" {
  source = "./modules/ecr"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "api"

  repositories = {
    backend = {
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
      encryption_type      = "AES256"

      lifecycle_policy = {
        max_image_count        = 30
        max_untagged_days      = 7
        max_tagged_days        = 90
        protected_tags         = ["latest", "prod"]
        enable_untagged_expiry = true
      }
    }

    frontend = {
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
    }
  }

  tags = {
    Project = "MyApp"
    Team    = "Platform"
  }
}
```

### Multiple Repositories with Different Configurations

```hcl
module "ecr" {
  source = "./modules/ecr"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "microservices"

  repositories = {
    api-gateway = {
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
      encryption_type      = "KMS"
      kms_key_arn          = aws_kms_key.ecr.arn

      lifecycle_policy = {
        max_image_count        = 50
        max_untagged_days      = 3
        max_tagged_days        = 180
        protected_tags         = ["latest", "prod", "v*"]
        enable_untagged_expiry = true
      }
    }

    user-service = {
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true

      lifecycle_policy = {
        max_image_count   = 20
        max_untagged_days = 7
        max_tagged_days   = 60
      }
    }

    auth-service = {
      scan_on_push = true
      force_delete = false  # Prevent accidental deletion
    }
  }

  tags = {
    Project = "Microservices"
  }
}
```

### Enhanced Scanning with AWS Inspector

```hcl
module "ecr" {
  source = "./modules/ecr"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "secure-app"

  repositories = {
    production-app = {
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
    }
  }

  # Enable enhanced scanning (additional cost)
  enable_enhanced_scanning = true
  scan_frequency           = "CONTINUOUS_SCAN"  # or "SCAN_ON_PUSH", "MANUAL"

  tags = {
    Compliance = "High"
  }
}
```

### Cross-Region Replication

```hcl
module "ecr" {
  source = "./modules/ecr"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "global-app"

  repositories = {
    web-app = {
      scan_on_push = true
    }
  }

  enable_replication = true
  replication_configuration = {
    rules = [
      {
        destinations = [
          {
            region      = "us-west-2"
            registry_id = "123456789012"  # Same or different account
          },
          {
            region      = "eu-west-1"
            registry_id = "123456789012"
          }
        ]
        repository_filters = [
          {
            filter      = "prod-*"
            filter_type = "PREFIX_MATCH"
          }
        ]
      }
    ]
  }
}
```

### Pull Through Cache for Public Registries

```hcl
module "ecr" {
  source = "./modules/ecr"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "platform"

  repositories = {
    my-app = {}
  }

  enable_pull_through_cache = true
  pull_through_cache_rules = {
    docker-hub = {
      upstream_registry_url = "registry-1.docker.io"
      credential_arn        = aws_secretsmanager_secret.dockerhub.arn
    }
    github = {
      upstream_registry_url = "ghcr.io"
      credential_arn        = aws_secretsmanager_secret.github.arn
    }
    quay = {
      upstream_registry_url = "quay.io"
    }
  }
}
```

### Repository with Custom Policy

```hcl
module "ecr" {
  source = "./modules/ecr"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "shared"

  repositories = {
    shared-images = {
      scan_on_push = true

      repository_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "AllowPullFromOtherAccounts"
            Effect = "Allow"
            Principal = {
              AWS = [
                "arn:aws:iam::111111111111:root",
                "arn:aws:iam::222222222222:root"
              ]
            }
            Action = [
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",
              "ecr:BatchCheckLayerAvailability"
            ]
          }
        ]
      })
    }
  }
}
```

## Docker Commands

After creating repositories, use these commands to push images:

```bash
# 1. Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.us-east-1.amazonaws.com

# 2. Build your Docker image
docker build -t my-app:latest .

# 3. Tag the image for ECR
docker tag my-app:latest \
  123456789012.dkr.ecr.us-east-1.amazonaws.com/myorg-prod-api-backend:latest

# 4. Push to ECR
docker push \
  123456789012.dkr.ecr.us-east-1.amazonaws.com/myorg-prod-api-backend:latest

# 5. Pull from ECR
docker pull \
  123456789012.dkr.ecr.us-east-1.amazonaws.com/myorg-prod-api-backend:latest
```

## Lifecycle Policy Behavior

The module creates a comprehensive lifecycle policy with these rules:

1. **Protected Tags**: Keep images with specified tags indefinitely (e.g., `latest`, `prod`, `production`)
2. **Tagged Image Expiry**: Remove tagged images older than `max_tagged_days` (default: 90 days)
3. **Image Count Limit**: Keep only `max_image_count` most recent images (default: 30)
4. **Untagged Image Expiry**: Remove untagged images older than `max_untagged_days` (default: 7 days)

Example lifecycle policy:
```hcl
lifecycle_policy = {
  max_image_count        = 30      # Keep only 30 most recent images
  max_untagged_days      = 7       # Delete untagged images after 7 days
  max_tagged_days        = 90      # Delete old tagged images after 90 days
  protected_tags         = ["latest", "prod", "v1.*"]  # Never delete these
  enable_untagged_expiry = true    # Enable untagged image cleanup
}
```

## Image Scanning

### Basic Scanning (Default)
- Free tier scanning using Clair
- Scans on push when `scan_on_push = true`
- Identifies common vulnerabilities (CVEs)

### Enhanced Scanning (AWS Inspector)
- Additional cost per image scanned
- Continuous vulnerability monitoring
- More comprehensive CVE database
- Operating system and programming language package scanning

```hcl
enable_enhanced_scanning = true
scan_frequency           = "CONTINUOUS_SCAN"  # or "SCAN_ON_PUSH", "MANUAL"
```

## Encryption

### AES256 (Default)
```hcl
encryption_type = "AES256"
```

### KMS
```hcl
encryption_type = "KMS"
kms_key_arn     = aws_kms_key.ecr.arn
```

## Image Tag Mutability

### MUTABLE (Default)
- Tags can be overwritten
- Useful for `latest` tags in development

### IMMUTABLE
- Tags cannot be overwritten
- Recommended for production
- Ensures reproducible builds

## Pull Through Cache

Pull through cache allows you to cache images from public registries in your private ECR:

**Benefits:**
- Faster pulls (cached in your region)
- Reduced rate limiting from public registries
- Improved availability
- Cost savings on data transfer

**Supported Registries:**
- Docker Hub: `registry-1.docker.io`
- GitHub Container Registry: `ghcr.io`
- Quay.io: `quay.io`
- Kubernetes Registry: `registry.k8s.io`
- Microsoft Container Registry: `mcr.microsoft.com`

**Usage:**
```bash
# Instead of: docker pull nginx:latest
# Use: docker pull 123456789012.dkr.ecr.us-east-1.amazonaws.com/docker-hub/nginx:latest
```

## Replication

Replicate images to multiple regions or accounts for:
- Disaster recovery
- Multi-region deployments
- Cross-account sharing
- Lower latency in different regions

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_prefix | Organization prefix for naming | string | - | yes |
| environment | Environment name | string | - | yes |
| workload | Workload or application name | string | - | yes |
| repositories | Map of ECR repository configurations | map(object) | {} | no |
| enable_enhanced_scanning | Enable AWS Inspector enhanced scanning | bool | false | no |
| scan_frequency | Scan frequency for enhanced scanning | string | "SCAN_ON_PUSH" | no |
| enable_replication | Enable cross-region replication | bool | false | no |
| replication_configuration | Replication configuration | object | {rules=[]} | no |
| enable_pull_through_cache | Enable pull through cache | bool | false | no |
| pull_through_cache_rules | Pull through cache rules | map(object) | {} | no |
| tags | Common tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_arns | Map of repository names to ARNs |
| repository_urls | Map of repository names to URLs |
| repository_names | Map of repository keys to full names |
| registry_id | The registry ID |
| registry_url | The ECR registry URL |
| docker_login_command | Command to authenticate Docker |
| docker_commands | Common Docker commands per repository |
| summary | Summary of ECR configuration |

## Examples

See the `workload-account/terraform.tfvars.example` file for comprehensive examples.

## Best Practices

1. **Use IMMUTABLE tags in production** to ensure reproducible deployments
2. **Enable scan_on_push** to catch vulnerabilities early
3. **Set aggressive lifecycle policies** for development repositories
4. **Use protected_tags** to prevent deletion of important images
5. **Enable KMS encryption** for sensitive applications
6. **Use pull through cache** to reduce rate limiting and improve reliability
7. **Enable replication** for disaster recovery and multi-region deployments
8. **Use repository policies** for cross-account access instead of making repositories public

## Cost Considerations

- **Storage**: $0.10 per GB per month
- **Data Transfer**: Standard AWS data transfer rates
- **Enhanced Scanning**: ~$0.09 per image scan (first scan free)
- **Replication**: Data transfer costs between regions
- **Pull Through Cache**: Storage and data transfer costs

## Notes

- Repository names will be prefixed with `{org_prefix}-{environment}-{workload}-`
- Lifecycle policies run once per day
- Enhanced scanning requires ECR to have permissions to AWS Inspector
- Pull through cache requires credentials stored in Secrets Manager for private registries
- Replication happens automatically after image push

## File Organization

- **versions.tf**: Terraform and provider version constraints
- **variables.tf**: Input variable definitions
- **data.tf**: Data sources and local values
- **repositories.tf**: ECR repository resources, lifecycle policies, scanning, replication
- **outputs.tf**: Output value definitions
- **README.md**: This file
- **CHANGELOG.md**: Version history and changes
