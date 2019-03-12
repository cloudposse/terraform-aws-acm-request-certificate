output "id" {
  value       = "${join("",aws_acm_certificate.default.*.id)}"
  description = "The ARN of the certificate"
}

output "arn" {
  value       = "${join("",aws_acm_certificate.default.*.arn)}"
  description = "The ARN of the certificate"
}

output "domain_validation_options" {
  value       = ["${aws_acm_certificate.default.*.domain_validation_options}"]
  description = "CNAME records that are added to the DNS zone to complete certificate validation"
}

output "email_validation_options" {
  value       = ["${aws_acm_certificate.default.*.validation_emails}"]
  description = " A list of addresses that received a validation E-Mail"
}


