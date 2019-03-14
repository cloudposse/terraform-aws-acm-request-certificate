locals {
  zone_name                = "${var.zone_name == "" ? var.domain_name : var.zone_name}"
  validation_enabled       = "${var.enabled == "true" && var.process_domain_validation_options == "true" ? true : false}"
  dns_validation_enabled   = "${local.validation_enabled == "true" && var.validation_method == "DNS" ? true : false}"
  dns_validation_records   = ["${flatten(aws_acm_certificate.default.*.domain_validation_options)}"]
  domains                  = ["${concat(list(var.domain_name), var.subject_alternative_names)}"]
  unique_domains           = ["${distinct(compact(split(" ",replace(join(" ", local.domains), "*.", ""))))}"]
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

resource "null_resource" "dns_records" {
  count   = "${local.dns_validation_enabled ? length(var.subject_alternative_names) + 1 : 0 }"
  triggers {
    name  = "${lookup(local.dns_validation_records[count.index], "resource_record_name", "")}"
    type  = "${lookup(local.dns_validation_records[count.index], "resource_record_type", "")}"
    value = "${lookup(local.dns_validation_records[count.index], "resource_record_value", "")}"
  }

  depends_on = ["aws_acm_certificate.default"]
}

resource "aws_route53_record" "default" {
  count   = "${local.dns_validation_enabled ? length(local.unique_domains) : 0 }"
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${element(distinct(aws_acm_certificate.default.0.domain_validation_options.*.resource_record_name), count.index)}"
  type    = "${element(distinct(aws_acm_certificate.default.0.domain_validation_options.*.resource_record_type), count.index)}"
  records = ["${element(distinct(aws_acm_certificate.default.0.domain_validation_options.*.resource_record_value), count.index)}"]
  ttl     = "${var.ttl}"
}

resource "aws_acm_certificate_validation" "dns" {
  count           = "${local.dns_validation_enabled ? 1 : 0}"
  certificate_arn = "${aws_acm_certificate.default.arn}"

  validation_record_fqdns = [
    "${distinct(concat(list(var.domain_name), var.subject_alternative_names))}",
  ]
}