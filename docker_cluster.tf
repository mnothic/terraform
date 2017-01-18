variable "env" {}

module "docker_cluster" {
  source                = "../modules/docker_cluster"
  code_name             = "${var.vpc_name}"
  ami                   = "ami-11286c71"
  manager_instance_type = "t2.small"
  node_instance_type    = "t2.micro"
  vol_size              = 8
  vol_type              = "gp2"
  tag_manager_name      = "${var.env}-ds-manager"
  tag_node_name         = "${var.env}-ds-node"
  tag_env               = "${var.env}"
  tag_stack             = "${var.env}"
  tag_type              = "docker"
  vpc_sg_ids            = "${module.network.sg_ofertia_hq_id}"
  key_name              = "JKEY"
  az                    = "${element(split(",",var.vpc_azs), 0)}"
  subnet_id             = "${element(split(",",module.network.public_subnet_ids), 0)}"
  sg_cidr               = "${var.vpc_cidr}"
}