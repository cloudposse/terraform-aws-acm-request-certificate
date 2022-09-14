output "id" {
  value       = join("", aws_acm_certificate.default.*.id)
  description = "The ID of the certificate"
}

output "arn" {
  value       = join("", aws_acm_certificate.default.*.arn)
  description = "The ARN of the certificate"
}

output "domain_validation_options" {
  value       = aws_acm_certificate.default.*.domain_validation_options
  description = "CNAME records that are added to the DNS zone to complete certificate validation"
}

output "validation_id" {
  value       = join("", aws_acm_certificate_validation.default.*.id)
  description = "The ID of the certificate validation"
}

output "validation_certificate_arn" {
  value       = join("", aws_acm_certificate_validation.default.*.certificate_arn)
  description = "Certificate ARN from the `aws_acm_certificate_validation` resource"
}

