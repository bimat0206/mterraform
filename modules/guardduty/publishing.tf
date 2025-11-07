# -----------------------------------------------------------------------------
# S3 Bucket for Findings Export
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "findings" {
  count = var.enable_guardduty && var.enable_s3_export ? 1 : 0

  bucket = local.s3_bucket_name

  tags = merge(
    local.common_tags,
    {
      Name = local.s3_bucket_name
    }
  )
}

resource "aws_s3_bucket_versioning" "findings" {
  count = var.enable_guardduty && var.enable_s3_export ? 1 : 0

  bucket = aws_s3_bucket.findings[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "findings" {
  count = var.enable_guardduty && var.enable_s3_export ? 1 : 0

  bucket = aws_s3_bucket.findings[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != "" ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null
    }
  }
}

resource "aws_s3_bucket_public_access_block" "findings" {
  count = var.enable_guardduty && var.enable_s3_export ? 1 : 0

  bucket = aws_s3_bucket.findings[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "findings" {
  count = var.enable_guardduty && var.enable_s3_export ? 1 : 0

  bucket = aws_s3_bucket.findings[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGuardDutyGetBucketLocation"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action   = "s3:GetBucketLocation"
        Resource = aws_s3_bucket.findings[0].arn
      },
      {
        Sid    = "AllowGuardDutyPutObject"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.findings[0].arn}/*"
      },
      {
        Sid    = "DenyUnencryptedObjectUploads"
        Effect = "Deny"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.findings[0].arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = var.kms_key_arn != "" ? "aws:kms" : "AES256"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.findings]
}

# -----------------------------------------------------------------------------
# GuardDuty Publishing Destination
# -----------------------------------------------------------------------------
resource "aws_guardduty_publishing_destination" "this" {
  count = var.enable_guardduty && var.enable_s3_export ? 1 : 0

  detector_id     = aws_guardduty_detector.this[0].id
  destination_arn = aws_s3_bucket.findings[0].arn
  kms_key_arn     = var.kms_key_arn != "" ? var.kms_key_arn : null

  destination_type = "S3"

  depends_on = [
    aws_s3_bucket_policy.findings
  ]
}
