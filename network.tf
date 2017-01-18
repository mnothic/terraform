variable "vpc_name"             {}
variable "vpc_cidr"             {}
variable "vpc_private_subnets"  {
  default = []
  type    = "list"
}
variable "vpc_public_subnets"   {}
variable "vpc_azs"              {}


module "network" {
  source          = "../modules/network"
  region          = "${var.region}"
  name            = "${var.vpc_name}"
  vpc_cidr        = "${var.vpc_cidr}"
  private_subnets = "${var.vpc_private_subnets}"
  public_subnets  = "${split(",", var.vpc_public_subnets)}"
  azs             = "${var.vpc_azs}"
}

# VPC
output "vpc_id"   { value = "${module.network.vpc_id}" }
output "vpc_cidr" { value = "${module.network.vpc_cidr}" }

# Subnets
output "private_subnet_ids" { value = "${module.network.private_subnet_ids}" }
output "public_subnet_ids" { value = "${module.network.public_subnet_ids}" }

# GW
output "gateway_id" { value = "${module.network.gateway_id}" }
#output "nat_gateway_ids" { value = "${module.network.nat_gateway_ids}" }

output "sg_hq_id" { value = "${module.network.sg_hq_id}" }
