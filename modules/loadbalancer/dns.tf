variable "route53_hosted_zone" {
  description = "The hosted zone where make ELB alias"
}

variable "alias_hostname" {
  description = "The host name (last dot) ELB alias"
}

variable "domain" {
  description = "The domain ELB alias"
}

resource "aws_route53_record" "dns" {
  zone_id                   = "${var.route53_hosted_zone}"
  name                      = "${var.alias_hostname}.${var.domain}"
  type                      = "A"

  alias {
    name                    = "${aws_elb.elb.dns_name}"
    zone_id                 = "${aws_elb.elb.zone_id}"
    evaluate_target_health  = false
  }
}
