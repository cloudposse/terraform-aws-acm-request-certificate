variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}

variable "domain_name" {
  type        = "string"
  description = "A domain name for which the certificate should be issued"
}

variable "validation_method" {
  type        = "string"
  default     = "DNS"
  description = "Which method to use for validation, DNS or EMAIL"
}

variable "process_domain_validation_options" {
  type        = "string"
  default     = "true"
  description = "Flag to enable/disable processing of the record to add to the DNS zone to complete certificate validation"
}

variable "ttl" {
  type        = "string"
  default     = "300"
  description = "The TTL of the record to add to the DNS zone to complete certificate validation"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map('BusinessUnit`,`XYZ`)"
}

variable "subject_alternative_names" {
  type        = "list"
  default     = []
  description = "A list of domains that should be SANs in the issued certificate"
}

variable "zone_name" {
  type        = "string"
  default     = ""
  description = "The name of the desired Route53 Hosted Zone"
}
