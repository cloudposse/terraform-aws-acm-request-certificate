locals {
  # Remove the var.domain_name from the subject_alternative_names as it doesn't need to be there.
  sans                      = ["${sort(distinct(compact(var.subject_alternative_names)))}"]
  domain_name_index_in_sans = "${contains(local.sans, var.domain_name) ? index(local.sans, var.domain_name) : -1 }"
  sans_left                 = ["${local.domain_name_index_in_sans > -1 ? slice(local.sans, 0, local.domain_name_index_in_sans) : local.sans }"]
  sans_right                = ["${local.domain_name_index_in_sans > -1 ? slice(local.sans, local.domain_name_index_in_sans + 1 , length(local.sans) ) : list() }"]
  subject_alternative_names = ["${concat(sans_left, sans_right)}"]
  zone_name                 = "${var.zone_name == "" ? var.domain_name : var.zone_name}"

}

resource "aws_acm_certificate" "default" {
  count                     = "${var.enabled == "true" ? 1 : 0}"
  domain_name               = "${var.domain_name}"
  validation_method         = "${var.validation_method}"
  subject_alternative_names = ["${local.subject_alternative_names}"]
  tags                      = "${var.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "default" {
  count        = "${var.process_domain_validation_options == "true" && var.validation_method == "DNS" ? 1 : 0}"
  name         = "${local.zone_name}."
  private_zone = false
}

resource "aws_acm_certificate_validation" "default" {
  count           = "${var.process_domain_validation_options == "true" ? 1 : 0}"
  certificate_arn = "${aws_acm_certificate.default.arn}"

  validation_record_fqdns = [
    "${distinct(compact(aws_route53_record.default.*.fqdn))}",
  ]
}

resource "aws_route53_record" "default" {
  count   = "${var.process_domain_validation_options == "true" && var.validation_method == "DNS" ? length(local.subject_alternative_names)  + 1 : 0 }"
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${lookup(aws_acm_certificate.default.domain_validation_options[count.index],"resource_record_name")}"
  type    = "${lookup(aws_acm_certificate.default.domain_validation_options[count.index], "resource_record_type")}"
  ttl     = "${var.ttl}"
  records = ["${lookup(aws_acm_certificate.default.domain_validation_options[count.index],"resource_record_value")}"]
}
