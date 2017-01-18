variable "vpc_name" {}

variable "sg_cidr" {
  description = "The allowed CIDR block from which ELB is accessible"
}

variable "vpc_id" {
  description = "The vpc id where ELB is attached"
}

module "sg_swarm" {
  source            = "../security/sg_swarm"
  vpc_id            = "${var.vpc_id}"
  sg_name           = "sg_swarm_${var.vpc_name}"
  source_cidr_block = "${var.sg_cidr}"
}

output "sg_swarm_id" {
  value = "${module.sg_swarm.sg_id}"
}