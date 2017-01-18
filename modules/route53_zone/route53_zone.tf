variable "domain" {}
variable "country" {}

resource "aws_route53_zone" "primary" {
  name = "${var.domain}"
  comment = ""
  tags {
    country = "${var.country}"
  }
}

output "zoneid" {
  value = "${aws_route53_zone.primary.zone_id}"
}
