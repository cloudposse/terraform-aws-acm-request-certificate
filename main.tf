resource "aws_acm_certificate" "default" {
  domain_name               = "${var.domain_name}"
  validation_method         = "${var.validation_method}"
  subject_alternative_names = ["${var.subject_alternative_names}"]
  tags                      = "${var.tags}"
}

data "aws_route53_zone" "default" {
  count        = "${var.process_domain_validation_options == "true" && var.validation_method == "DNS" ? 1 : 0}"
  name         = "${var.domain_name}."
  private_zone = false
}

locals {
  # Workaround for https://github.com/hashicorp/terraform/issues/18359
  domain_validation_options = "${flatten(aws_acm_certificate.default.*.domain_validation_options)}"
}

resource "aws_route53_record" "default" {
  count   = "${var.process_domain_validation_options == "true" && var.validation_method == "DNS" ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${lookup(local.domain_validation_options[count.index], "resource_record_name")}"
  type    = "${lookup(local.domain_validation_options[count.index], "resource_record_type")}"
  ttl     = "${var.ttl}"
  records = ["${lookup(local.domain_validation_options[count.index], "resource_record_value")}"]
}
