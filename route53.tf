module "route53_zone" {
  source  = "../modules/route53_zone"
  domain  = "${var.domain}."
  country = "${var.country}"
}

output "route53_zone_id" {
  value = "${module.route53_zone.zoneid}"
}
