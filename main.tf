resource "null_resource" "certificate_request" {
  triggers {
    domain = "${var.domain_name}"
  }

  provisioner "local-exec" {
    command = "aws acm request-certificate --domain-name ${var.domain_name} --subject-alternative-names ${element(var.subject_alternative_names, count.index)} > ${path.module}/skeleton.json"
  }
}

data "external" "default" {
  program = ["cat", "${path.module}/skeleton.json"]
}

output "arn" {
  value = "${data.external.default.result.CertificateArn}"
}
