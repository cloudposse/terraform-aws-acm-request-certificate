variable "domain_name" {
  type        = "string"
  description = "A domain name for which the certificate should be issued"
}

variable "proces_domain_validation_options" {
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
