# -----------------------------------------------------------------------------
# Certificate Outputs
# -----------------------------------------------------------------------------
output "certificate_arn" {
  description = "The ARN of the certificate"
  value       = aws_acm_certificate.this.arn
}

output "certificate_id" {
  description = "The ID of the certificate"
  value       = aws_acm_certificate.this.id
}

output "certificate_name" {
  description = "The name of the certificate"
  value       = local.name
}

output "certificate_domain_name" {
  description = "The domain name of the certificate"
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_status" {
  description = "The status of the certificate"
  value       = aws_acm_certificate.this.status
}

output "certificate_validation_status" {
  description = "The validation status of the certificate"
  value       = aws_acm_certificate_validation.this.id
}

output "domain_validation_options" {
  description = "Domain validation options for the certificate"
  value       = aws_acm_certificate.this.domain_validation_options
}
