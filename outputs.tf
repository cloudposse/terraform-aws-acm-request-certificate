output "id" {
  value = "${aws_acm_certificate.default.id}"
}

output "arn" {
  value = "${aws_acm_certificate.default.arn}"
}

output "domain_validation_options" {
  value = "${aws_acm_certificate.default.domain_validation_options}"
}
