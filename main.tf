locals {
  zone_name                 = "${var.zone_name == "" ? var.domain_name : var.zone_name}"
  dns_validation_enabled    = "${var.enabled == "true" && var.process_domain_validation_options == "true" && var.validation_method == "DNS" ? "true" : "false"}"
}

resource "aws_acm_certificate" "default" {
  count                     = "${var.enabled == "true" ? 1 : 0}"
  domain_name               = "${var.domain_name}"
  validation_method         = "${var.validation_method}"
  subject_alternative_names = ["${var.subject_alternative_names}"]
  tags                      = "${var.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "default" {
  count        = "${local.dns_validation_enabled == "true" ? 1 : 0}"
  name         = "${local.zone_name}"
  private_zone = false
}

resource "aws_route53_record" "default" {
  count   = "${local.dns_validation_enabled ? length(aws_acm_certificate.default.domain_validation_options) : 0 }"
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${lookup(aws_acm_certificate.default.domain_validation_options[count.index], "resource_record_name")}"
  type    = "${lookup(aws_acm_certificate.default.domain_validation_options[count.index], "resource_record_type")}"
  records = ["${lookup(aws_acm_certificate.default.domain_validation_options[count.index], "resource_record_value")}"]
  ttl     = "${var.ttl}"
}

resource "aws_acm_certificate_validation" "default" {
  count           = "${var.enabled == "true" && var.process_domain_validation_options == "true" ? 1 : 0}"
  certificate_arn = "${aws_acm_certificate.default.arn}"

  validation_record_fqdns = [
    "${distinct(compact(aws_acm_certificate.default.domain_validation_options.*.domain_name))}",
  ]
}