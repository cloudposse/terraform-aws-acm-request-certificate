provider "aws" {
  region = var.region
}

module "zone" {
  source           = "cloudposse/route53-cluster-zone/aws"
  version          = "0.12.0"
  parent_zone_name = var.parent_zone_name
  zone_name        = "$${name}.$${parent_zone_name}"

  context = module.this.context
}

module "acm_request_certificate" {
  source                            = "../../"
  domain_name                       = module.zone.zone_name
  validation_method                 = var.validation_method
  ttl                               = var.ttl
  subject_alternative_names         = ["*.${module.zone.zone_name}"]
  process_domain_validation_options = var.process_domain_validation_options
  wait_for_certificate_issued       = var.wait_for_certificate_issued

  context = module.this.context
}
