output "id" {
  value       = "${aws_acm_certificate.default.id}"
  description = "The ARN of the certificate"
}

output "arn" {
  value       = "${aws_acm_certificate_validation.default.certificate_arn}"
  description = "The ARN of the certificate"
}

output "domain_validation_options" {
  value       = "${aws_acm_certificate.default.domain_validation_options}"
  description = "CNAME records that are added to the DNS zone to complete certificate validation"
}
