variable "country" {
  description = "The country environment"
}

variable "name" {
  description = "The name identifier of RDS"
}

variable "source_sg" {
  description = "The SG ids which RDS grants access"
  type = "list"
}

variable "source_cidr" {
  description = "The cidrs which RDS grants access"
  type = "list"
  default = []
}

variable "vpc_id" {
  description = "The vpc id where RDS is attached"
}

module "sg_rds" {
  source            = "../security/sg_postgres"
  vpc_id            = "${var.vpc_id}"
  sg_name           = "sg_db_${replace(var.name,"-","_")}"
  source_sg         = "${var.source_sg}"
  source_cidr       = "${var.source_cidr}"
}

output "sg_rds_id" {
  value = "${module.sg_rds.sg_id}"
}
