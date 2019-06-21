resource "aws_acm_certificate" "default" {
  domain_name               = var.domain_name
  validation_method         = var.validation_method
  subject_alternative_names = var.subject_alternative_names
  tags                      = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "default" {
  count        = var.process_domain_validation_options == "true" && var.validation_method == "DNS" ? 1 : 0
  name         = "${local.zone_name}."
  private_zone = false
}

locals {
  domain_validation_options = aws_acm_certificate.default.domain_validation_options[0]
  zone_name                 = var.zone_name == "" ? var.domain_name : var.zone_name
}

resource "null_resource" "default" {
  count = var.process_domain_validation_options == "true" && var.validation_method == "DNS" ? length(aws_acm_certificate.default.domain_validation_options) : 0

  triggers = aws_acm_certificate.default.domain_validation_options[count.index]
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.default.arn

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  validation_record_fqdns = [
    distinct(
      compact(
        concat(
          aws_route53_record.default[0].fqdn,
          var.subject_alternative_names,
        ),
      ),
    ),
  ]
}

resource "aws_route53_record" "default" {
  count   = length(null_resource.default[0].triggers)
  zone_id = data.aws_route53_zone.default[0].zone_id
  name    = "null_resource.default.${count.index}" ["resource_record_name"]
  type    = "null_resource.default.${count.index}" ["resource_record_type"]
  ttl     = var.ttl
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  records = ["null_resource.default.${count.index}" ["resource_record_value"]]
}

