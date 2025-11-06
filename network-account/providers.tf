provider "aws" {
  region = var.region

  # Optional: Configure AWS profile or assume role
  # profile = var.aws_profile
  # assume_role {
  #   role_arn = var.assume_role_arn
  # }

  # Default tags applied to all supported resources
  default_tags {
    tags = {
      terraform   = "true"
      managed-by  = "terraform"
      org         = var.org_prefix
      environment = var.environment
      workload    = var.workload
    }
  }
}
