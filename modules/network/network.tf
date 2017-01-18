variable "name"                 {}
variable "region"               {}
variable "vpc_cidr"             {}
variable "azs"                  {}
variable "private_subnets"      {
  default = []
  type    = "list"
}
variable "public_subnets"       {
  type    = "list"
}

module "vpc" {
  source   = "./vpc"
  vpc_cidr = "${var.vpc_cidr}"
  vpc_name = "${var.name}"
}

/* we don't use this nowadays
module "nat" {
  source             = "./nat"
  name               = "${var.name}-nat"
  azs                = "${var.azs}"
  private_subnet_ids = "${module.private_subnet.subnet_ids}"
}
*/

module "private_subnet" {
  source                = "./private_subnet"
  name                  = "${var.name}-private"
  vpc_id                = "${module.vpc.vpc_id}"
  cidrs                 = "${var.private_subnets}"
  azs                   = "${var.azs}"
}

module "public_subnet" {
  source                = "./public_subnet"
  name                  = "${var.name}-public"
  vpc_id                = "${module.vpc.vpc_id}"
  cidrs                 = "${var.public_subnets}"
  azs                   = "${var.azs}"
}

module "sg_hq" {
  source            = "../security/sg_hq"
  vpc_id            = "${module.vpc.vpc_id}"
  sg_name           = "sg_hq_vpc_${var.name}"
  source_cidr_block = "0.0.0.0/0"
}

# VPC
output "vpc_id"   { value = "${module.vpc.vpc_id}" }
output "vpc_cidr" { value = "${module.vpc.vpc_cidr}" }
output "sg_hq_id" { value = "${module.sg_hq.sg_id}" }

# Subnets
output "private_subnet_ids"   { value = "${module.private_subnet.subnet_ids}" }
output "public_subnet_ids"   { value = "${module.public_subnet.subnet_ids}" }

# GW
output "gateway_id" { value = "${module.public_subnet.gateway_id}" }
#output "nat_gateway_ids" { value = "${module.nat.nat_gateway_ids}" }
