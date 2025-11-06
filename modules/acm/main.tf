# -----------------------------------------------------------------------------
# Dynamic naming and tagging locals
# -----------------------------------------------------------------------------
locals {
  # Pick module default service if not provided
  _service = coalesce(var.service, "acm")

  # Join tokens, drop empties
  _tokens = compact([var.org_prefix, var.environment, var.workload, local._service, var.identifier])
  _raw    = join("-", local._tokens)

  # Normalize to AWS-friendly style: lowercase + hyphens only
  name = trim(regexreplace(lower(local._raw), "[^a-z0-9-]", "-"), "-")

  # Combine domain_name with SANs
  all_domains = distinct(concat([var.domain_name], var.subject_alternative_names))
}

# -----------------------------------------------------------------------------
# ACM Certificate
# -----------------------------------------------------------------------------
resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = length(var.subject_alternative_names) > 0 ? var.subject_alternative_names : null
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = local.name
  })
}

# -----------------------------------------------------------------------------
# DNS Validation Records
# -----------------------------------------------------------------------------
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.validation_ttl
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

# -----------------------------------------------------------------------------
# Certificate Validation
# -----------------------------------------------------------------------------
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
