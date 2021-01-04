resource "aws_acm_certificate" "default" {
  count                     = local.enabled ? 1 : 0
  domain_name               = var.domain_name
  validation_method         = var.validation_method
  subject_alternative_names = var.subject_alternative_names
  tags                      = module.this.tags

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  enabled                           = module.this.enabled
  zone_name                         = var.zone_name == "" ? "${var.domain_name}." : var.zone_name
  process_domain_validation_options = local.enabled && var.process_domain_validation_options && var.validation_method == "DNS"
  domain_validation_options_list    = local.process_domain_validation_options ? tolist(aws_acm_certificate.default.0.domain_validation_options) : []
}

data "aws_route53_zone" "default" {
  count        = local.process_domain_validation_options ? 1 : 0
  name         = local.zone_name
  private_zone = false
}

resource "aws_route53_record" "default" {
  for_each = {
    for dvo in local.domain_validation_options_list : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id         = join("", data.aws_route53_zone.default.*.zone_id)
  ttl             = var.ttl
  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
}

resource "aws_acm_certificate_validation" "default" {
  count                   = local.process_domain_validation_options && var.wait_for_certificate_issued ? 1 : 0
  certificate_arn         = join("", aws_acm_certificate.default.*.arn)
  validation_record_fqdns = [for record in aws_route53_record.default : record.fqdn]
}
