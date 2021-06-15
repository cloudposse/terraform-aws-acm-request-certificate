variable "region" {
  type        = string
  description = "AWS region"
}

variable "parent_zone_name" {
  type        = string
  description = "Parent DNS zone name"
}

variable "validation_method" {
  type        = string
  description = "Method to use for validation, DNS or EMAIL"
}

variable "process_domain_validation_options" {
  type        = bool
  description = "Flag to enable/disable processing of the record to add to the DNS zone to complete certificate validation"
}

variable "ttl" {
  type        = string
  description = "The TTL of the record to add to the DNS zone to complete certificate validation"
}

variable "wait_for_certificate_issued" {
  type        = bool
  description = "Whether to wait for the certificate to be issued by ACM (the certificate status changed from `Pending Validation` to `Issued`)"
}
