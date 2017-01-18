variable "sg_cidr" {
  description = "The allowed CIDR block from which ELB is accessible"
}

variable "vpc_id" {
  description = "The vpc id where ELB is attached"
}

module "sg_elb" {
  source            = "../security/sg_http_https"
  vpc_id            = "${var.vpc_id}"
  sg_name           = "sg_lb_${var.project}_${var.country}"
  source_cidr_block = "${var.sg_cidr}"
}

output "sg_elb_id" {
  value = "${module.sg_elb.sg_id}"
}