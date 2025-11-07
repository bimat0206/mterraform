# -----------------------------------------------------------------------------
# S3 Bucket for Config Delivery Channel
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "config" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = local.s3_bucket_name

  tags = merge(
    local.common_tags,
    {
      Name = local.s3_bucket_name
    }
  )
}

resource "aws_s3_bucket_versioning" "config" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.config[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.config[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.config[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "config" {
  count = var.create_s3_bucket && var.s3_bucket_lifecycle_days > 0 ? 1 : 0

  bucket = aws_s3_bucket.config[0].id

  rule {
    id     = "expire-old-config-snapshots"
    status = "Enabled"

    expiration {
      days = var.s3_bucket_lifecycle_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.s3_bucket_lifecycle_days
    }
  }
}

resource "aws_s3_bucket_policy" "config" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.config[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config[0].arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = local.account_id
          }
        }
      },
      {
        Sid    = "AWSConfigBucketExistenceCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.config[0].arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = local.account_id
          }
        }
      },
      {
        Sid    = "AWSConfigBucketPutObject"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config[0].arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"      = "bucket-owner-full-control"
            "AWS:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.config]
}
