output "certificate_arn" {
  description = "The ARN of the certificate"
  value       = aws_acm_certificate.this.arn
}

output "domain_name" {
  description = "The domain name for which the certificate is issued"
  value       = aws_acm_certificate.this.domain_name
}

output "validation_emails" {
  description = "A list of addresses that received a validation E-Mail"
  value       = aws_acm_certificate.this.validation_emails
}