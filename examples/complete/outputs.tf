output "parent_zone_id" {
  value = module.zone.parent_zone_id
}

output "parent_zone_name" {
  value = module.zone.parent_zone_name
}

output "zone_id" {
  value = module.zone.zone_id
}

output "zone_name" {
  value = module.zone.zone_name
}

output "zone_fqdn" {
  value = module.zone.fqdn
}

output "certificate_id" {
  value       = module.acm_request_certificate.id
  description = "The ID of the certificate"
}

output "certificate_arn" {
  value       = module.acm_request_certificate.arn
  description = "The ID of the certificate"
}

output "certificate_domain_validation_options" {
  value       = module.acm_request_certificate.domain_validation_options
  description = "CNAME records that are added to the DNS zone to complete certificate validation"
}
