resource "aws_acm_certificate" "default" {
  count                     = var.enabled ? 1 : 0
  domain_name               = var.domain_name
  validation_method         = var.validation_method
  subject_alternative_names = var.subject_alternative_names
  tags                      = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  zone_name                         = var.zone_name == "" ? var.domain_name : var.zone_name
  process_domain_validation_options = var.enabled && var.process_domain_validation_options && var.validation_method == "DNS"
  domain_validation_options_list    = local.process_domain_validation_options ? aws_acm_certificate.default.0.domain_validation_options : []
}

data "aws_route53_zone" "default" {
  provider     = aws.route53_zone_provider
  count        = local.process_domain_validation_options ? 1 : 0
  name         = "${local.zone_name}."
  private_zone = false
}

resource "aws_route53_record" "default" {
  provider        = aws.route53_zone_provider
  count           = local.process_domain_validation_options ? length(var.subject_alternative_names) + 1 : 0
  zone_id         = join("", data.aws_route53_zone.default.*.zone_id)
  ttl             = var.ttl
  allow_overwrite = true
  name            = lookup(local.domain_validation_options_list[count.index], "resource_record_name")
  type            = lookup(local.domain_validation_options_list[count.index], "resource_record_type")
  records         = [lookup(local.domain_validation_options_list[count.index], "resource_record_value")]
}

resource "aws_acm_certificate_validation" "default" {
  count                   = local.process_domain_validation_options && var.wait_for_certificate_issued ? 1 : 0
  certificate_arn         = join("", aws_acm_certificate.default.*.arn)
  validation_record_fqdns = aws_route53_record.default.*.fqdn
}
