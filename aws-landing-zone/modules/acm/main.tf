# Use the common tag module
module "tags" {
  source = "../../../common-modules/tag"

  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center
  project_name = var.project_name
}

# Create ACM certificate
resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = var.subject_alternative_names

  tags = merge(
    module.tags.tags,
    var.tags,
    {
      Name = "${var.name_prefix}-${var.name}"
    }
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags["CreationDate"]]
  }
}

# DNS validation records
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
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
