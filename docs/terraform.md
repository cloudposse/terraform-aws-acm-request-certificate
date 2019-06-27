## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| domain_name | A domain name for which the certificate should be issued | string | - | yes |
| enabled | Set to false to prevent the module from creating or accessing any resources | bool | `true` | no |
| process_domain_validation_options | Flag to enable/disable processing of the record to add to the DNS zone to complete certificate validation | bool | `true` | no |
| subject_alternative_names | A list of domains that should be SANs in the issued certificate | list(string) | `<list>` | no |
| tags | Additional tags (e.g. map('BusinessUnit`,`XYZ`) | map(string) | `<map>` | no |
| ttl | The TTL of the record to add to the DNS zone to complete certificate validation | string | `300` | no |
| validation_method | Method to use for validation, DNS or EMAIL | string | `DNS` | no |
| zone_name | The name of the desired Route53 Hosted Zone | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the certificate |
| domain_validation_options | CNAME records that are added to the DNS zone to complete certificate validation |
| id | The ID of the certificate |

