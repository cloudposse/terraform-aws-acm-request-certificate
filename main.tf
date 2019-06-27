resource "aws_acm_certificate" "default" {
  domain_name               = var.domain_name
  validation_method         = var.validation_method
  subject_alternative_names = var.subject_alternative_names
  tags                      = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  zone_name = var.zone_name == "" ? var.domain_name : var.zone_name
}

data "aws_route53_zone" "default" {
  count        = var.process_domain_validation_options && var.validation_method == "DNS" ? 1 : 0
  name         = "${local.zone_name}."
  private_zone = false
}

resource "aws_route53_record" "default" {
  count   = var.process_domain_validation_options && var.validation_method == "DNS" ? length(aws_acm_certificate.default.domain_validation_options) : 0
  zone_id = join("", data.aws_route53_zone.default.*.zone_id)
  name    = lookup(aws_acm_certificate.default.domain_validation_options[count.index], "resource_record_name")
  type    = lookup(aws_acm_certificate.default.domain_validation_options[count.index], "resource_record_type")
  ttl     = var.ttl
  records = [lookup(aws_acm_certificate.default.domain_validation_options[count.index], "resource_record_value")]
}

resource "aws_acm_certificate_validation" "default" {
  count                   = var.process_domain_validation_options ? 1 : 0
  certificate_arn         = aws_acm_certificate.default.arn
  validation_record_fqdns = distinct(compact(concat(aws_route53_record.default.*.fqdn, var.subject_alternative_names)))
}
