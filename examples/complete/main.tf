provider "aws" {
  region = var.region
}

module "zone" {
  source           = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-zone.git?ref=tags/0.4.0"
  namespace        = var.namespace
  stage            = var.stage
  name             = var.name
  parent_zone_name = var.parent_zone_name
  zone_name        = "$${name}.$${parent_zone_name}"
}

module "acm_request_certificate" {
  source                            = "../../"
  domain_name                       = module.zone.zone_name
  process_domain_validation_options = var.process_domain_validation_options
  validation_method                 = var.validation_method
  ttl                               = var.ttl
  subject_alternative_names         = [concat("*.", module.zone.zone_name)]
}
