locals {
  zone_name                = "${var.zone_name == "" ? var.domain_name : var.zone_name}"
  validation_enabled       = "${var.enabled == "true" && var.process_domain_validation_options == "true" ? true : false}"
  dns_validation_enabled   = "${local.validation_enabled && var.validation_method == "DNS" ? true : false}"
  dns_validation_records   = ["${aws_acm_certificate.default.domain_validation_options}"]
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
  count        = "${local.dns_validation_enabled ? 1 : 0}"
  name         = "${local.zone_name}"
  private_zone = false
}

resource "aws_route53_record" "default" {
  count   = "${local.dns_validation_enabled ? length(var.subject_alternative_names) + 1 : 0 }"
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${lookup(length(local.dns_validation_records) != 0 ? map(element(local.dns_validation_records, count.index)) : map(), "resource_record_name", "")}"
  type    = "${lookup(length(local.dns_validation_records) != 0 ? map(element(local.dns_validation_records, count.index)) : map(), "resource_record_type", "")}"
  records = ["${lookup(length(local.dns_validation_records) != 0 ? map(element(local.dns_validation_records, count.index)) : map(), "resource_record_value", "")}"]
  ttl     = "${var.ttl}"
}

resource "aws_acm_certificate_validation" "dns" {
  count           = "${local.dns_validation_enabled ? 1 : 0}"
  certificate_arn = "${aws_acm_certificate.default.arn}"

  validation_record_fqdns = [
    "${distinct(concat(list(var.domain_name), var.subject_alternative_names))}",
  ]
}