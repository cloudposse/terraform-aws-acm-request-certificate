## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| domain_name | A domain name for which the certificate should be issued | string | - | yes |
| proces_domain_validation_options | Flag to enable/disable processing of the record to add to the DNS zone to complete certificate validation | string | `true` | no |
| subject_alternative_names | A list of domains that should be SANs in the issued certificate | list | `<list>` | no |
| tags | Additional tags (e.g. map('BusinessUnit`,`XYZ`) | map | `<map>` | no |
| ttl | The TTL of the record to add to the DNS zone to complete certificate validation | string | `300` | no |
| validation_method | Which method to use for validation, DNS or EMAIL | string | `DNS` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the certificate |
| domain_validation_options | CNAME records that are added to the DNS zone to complete certificate validation |
| id | The ARN of the certificate |

