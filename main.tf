locals {
  enabled                           = module.this.enabled
  process_domain_validation_options = local.enabled && var.process_domain_validation_options && var.validation_method == "DNS"
  domain_validation_options_set     = local.process_domain_validation_options ? aws_acm_certificate.default.0.domain_validation_options : toset([])

  all_domains = concat(
    [var.domain_name],
    var.subject_alternative_names
  )
  domain_to_zone = {
    for domain in local.all_domains :
    domain => join(".", slice(split(".", domain), 1, length(split(".", domain))))
  }
  unique_zones = distinct(values(local.domain_to_zone))
}

resource "aws_acm_certificate" "default" {
  count                     = local.enabled ? 1 : 0
  domain_name               = var.domain_name
  validation_method         = var.validation_method
  subject_alternative_names = var.subject_alternative_names
  certificate_authority_arn = var.certificate_authority_arn

  options {
    certificate_transparency_logging_preference = var.certificate_transparency_logging_preference ? "ENABLED" : "DISABLED"
  }

  tags = module.this.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "default" {
  for_each     = local.process_domain_validation_options ? toset(local.unique_zones) : toset([])
  zone_id      = var.zone_id
  name         = try(length(var.zone_id), 0) == 0 ? each.key : null
  private_zone = false
}

resource "aws_route53_record" "default" {
  for_each = {
    for dvo in local.domain_validation_options_set : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id         = data.aws_route53_zone.default[local.domain_to_zone[each.key]].id
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
