output "id" {
  value       = "${join("",aws_acm_certificate.default.*.id)}"
  description = "The ARN of the certificate"
}

output "arn" {
  value       = "${join("",compact(concat(aws_acm_certificate_validation.dns.*.certificate_arn, aws_acm_certificate_validation.email.*.certificate_arn)))}"
  description = "The ARN of the certificate"
}

output "domain_validation_options" {
  value       = ["${aws_acm_certificate.default.*.domain_validation_options}"]
  description = "CNAME records that are added to the DNS zone to complete certificate validation"
}
