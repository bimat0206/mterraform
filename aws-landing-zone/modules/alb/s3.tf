# S3 bucket resources for ALB logs

# Generate a random suffix for the S3 bucket
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Get the current AWS account ID
data "aws_caller_identity" "current" {}

# Get the ELB service account ID
data "aws_elb_service_account" "main" {}

# Get the current AWS region
data "aws_region" "current" {}

# --- Access Logs Bucket ---
resource "aws_s3_bucket" "access_logs" {
  count = local.access_logs_enabled && length(var.access_logs_bucket) == 0 ? 1 : 0
  
  bucket = lower(
    substr(
      replace(
        "${local.alb_name}-access-logs-${data.aws_region.current.name}-${random_id.bucket_suffix.hex}",
        "_", "-"
      ),
      0,
      63
    )
  )
  
  tags = merge(
    local.alb_tags,
    {
      Name = "${local.alb_name}-alb-access-logs-${random_id.bucket_suffix.hex}"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# --- Connection Logs Bucket ---
resource "aws_s3_bucket" "connection_logs" {
  count = local.connection_logs_enabled && length(var.connection_logs_bucket) == 0 ? 1 : 0
  
  bucket = lower(
    substr(
      replace(
        "${local.alb_name}-conn-logs-${data.aws_region.current.name}-${random_id.bucket_suffix.hex}",
        "_", "-"
      ),
      0,
      63
    )
  )
  
  tags = merge(
    local.alb_tags,
    {
      Name = "${local.alb_name}-alb-connection-logs-${random_id.bucket_suffix.hex}"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# --- S3 Bucket Versioning ---
resource "aws_s3_bucket_versioning" "access_logs" {
  count = local.access_logs_enabled && length(var.access_logs_bucket) == 0 ? 1 : 0
  
  bucket = aws_s3_bucket.access_logs[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "connection_logs" {
  count = local.connection_logs_enabled && length(var.connection_logs_bucket) == 0 ? 1 : 0
  
  bucket = aws_s3_bucket.connection_logs[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# --- S3 Bucket Encryption ---
resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count = local.access_logs_enabled && length(var.access_logs_bucket) == 0 ? 1 : 0
  
  bucket = aws_s3_bucket.access_logs[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "connection_logs" {
  count = local.connection_logs_enabled && length(var.connection_logs_bucket) == 0 ? 1 : 0
  
  bucket = aws_s3_bucket.connection_logs[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --- S3 Bucket Lifecycle ---
resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  count = local.access_logs_enabled && length(var.access_logs_bucket) == 0 ? 1 : 0
  
  bucket = aws_s3_bucket.access_logs[0].id
  
  rule {
    id     = "log-expiration"
    status = "Enabled"
    
    filter {
      prefix = ""
    }
    
    expiration {
      days = var.logs_expiration_days
    }
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "connection_logs" {
  count = local.connection_logs_enabled && length(var.connection_logs_bucket) == 0 ? 1 : 0
  
  bucket = aws_s3_bucket.connection_logs[0].id
  
  rule {
    id     = "log-expiration"
    status = "Enabled"
    
    filter {
      prefix = ""
    }
    
    expiration {
      days = var.logs_expiration_days
    }
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

# --- S3 Bucket Policies ---
resource "aws_s3_bucket_policy" "access_logs" {
  count = local.access_logs_enabled && length(var.access_logs_bucket) == 0 ? 1 : 0
  
  bucket = aws_s3_bucket.access_logs[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowELBRootAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::114774131450:root"
        }
        Action = "*"
        Resource = "${aws_s3_bucket.access_logs[0].arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "connection_logs" {
  count = local.connection_logs_enabled && length(var.connection_logs_bucket) == 0 ? 1 : 0
  
  bucket = aws_s3_bucket.connection_logs[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::114774131450:root"
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.connection_logs[0].arn}/${var.connection_logs_prefix}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::114774131450:root"
        }
        Action = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.connection_logs[0].arn
      }
    ]
  })
}

# --- S3 Bucket Public Access Block ---
resource "aws_s3_bucket_public_access_block" "access_logs" {
  count = local.access_logs_enabled && length(var.access_logs_bucket) == 0 ? 1 : 0
  
  bucket = aws_s3_bucket.access_logs[0].id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "connection_logs" {
  count = local.connection_logs_enabled && length(var.connection_logs_bucket) == 0 ? 1 : 0
  
  bucket = aws_s3_bucket.connection_logs[0].id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- S3 Bucket Ownership Controls ---
resource "aws_s3_bucket_ownership_controls" "access_logs" {
  count = local.access_logs_enabled && length(var.access_logs_bucket) == 0 ? 1 : 0
  
  bucket = aws_s3_bucket.access_logs[0].id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_ownership_controls" "connection_logs" {
  count = local.connection_logs_enabled && length(var.connection_logs_bucket) == 0 ? 1 : 0
  
  bucket = aws_s3_bucket.connection_logs[0].id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}