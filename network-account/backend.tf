# S3 backend configuration
# Values are provided via -backend-config file
# Example: terraform init -backend-config=backend.hcl
terraform {
  backend "s3" {
    # bucket         = "provided-via-backend-config"
    # key            = "provided-via-backend-config"
    # region         = "provided-via-backend-config"
    # dynamodb_table = "provided-via-backend-config"
    # encrypt        = true
  }
}
