locals {
  zone_name              = "${var.zone_name == "" ? var.domain_name : var.zone_name}"
  validation_enabled     = "${var.enabled == "true" && var.process_domain_validation_options == "true" ? true : false}"
  dns_validation_enabled = "${local.validation_enabled == "true" && var.validation_method == "DNS" ? true : false}"
  domains                = ["${concat(list(var.domain_name), var.subject_alternative_names)}"]
  unique_domains         = ["${distinct(compact(split(" ",replace(join(" ", local.domains), "*.", ""))))}"]
}

resource "aws_acm_certificate" "default" {
  count                     = "${var.enabled == "true" ? 1 : 0}"
  domain_name               = "${var.domain_name}"
  validation_method         = "${var.validation_method}"
  subject_alternative_names = ["${var.subject_alternative_names}"]
  tags                      = "${var.tags}"
}

data "aws_route53_zone" "default" {
  count        = "${local.dns_validation_enabled ? 1 : 0}"
  name         = "${local.zone_name}"
  private_zone = false
}

data "null_data_source" "dns_records" {
  count = "${local.dns_validation_enabled ? length(local.domains) : 1 }"

  inputs {
    #record = "${format("%s:%s:%s", lookup(aws_acm_certificate.default.*.domain_validation_options.0[count.index], "resource_record_name", ""), lookup(aws_acm_certificate.default.*.domain_validation_options[count.index], "resource_record_type", ""), lookup(aws_acm_certificate.default.*.domain_validation_options[count.index], "resource_record_value", ""))}"
    record = "${ lookup( aws_acm_certificate.default.*.domain_validation_options[count.index], "resource_record_name", "1")}"
  }
  has_computed_default = true
}
//
/*
resource "aws_route53_record" "default" {
  count   = "${local.dns_validation_enabled ? length(local.unique_domains) : 0 }"
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${element(distinct(aws_acm_certificate.default.0.domain_validation_options.*.resource_record_name), count.index)}"
  type    = "${element(distinct(aws_acm_certificate.default.0.domain_validation_options.*.resource_record_type), count.index)}"
  records = ["${element(distinct(aws_acm_certificate.default.0.domain_validation_options.*.resource_record_value), count.index)}"]
  ttl     = "${var.ttl}"

  depends_on = ["aws_acm_certificate.default"]
}
*/
//
//resource "aws_acm_certificate_validation" "dns" {
//  count           = "${local.dns_validation_enabled ? 1 : 0}"
//  certificate_arn = "${aws_acm_certificate.default.arn}"
//
//  validation_record_fqdns = [
//    "${aws_route53_record.default.*.fqdn}",
//  ]
//}
