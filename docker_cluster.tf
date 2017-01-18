
module "docker_cluster" {
  source                = "../modules/docker_cluster"
  vpc_name              = "${var.vpc_name}"
  vpc_id                = "${module.network.vpc_id}"
  code_name             = "${var.vpc_name}_docker_cluster"
  ami                   = "ami-a2b3eac4"
  manager_instance_type = "t2.medium"
  node_instance_type    = "t2.small"
  m_vol_size            = 60
  n_vol_size            = 20
  vol_type              = "gp2"
  tag_manager_name      = "${var.env}-ds-manager"
  tag_node_name         = "${var.env}-ds-node"
  tag_env               = "${var.env}"
  tag_stack             = "${var.env}"
  tag_type              = "docker"
  vpc_sg_ids            = "${module.network.sg_hq_id}"
  key_name              = "jenkins"
  az                    = "${element(split(",",var.vpc_azs), 0)}"
  subnet_id             = "${element(split(",",module.network.public_subnet_ids), 0)}"
  sg_cidr               = "${var.vpc_cidr}"
  private_key           = "~/21buttons/jenkins.pem"
  swarm_manager_count   = 1
  swarm_node_count      = 1
}

output "swarm_managers" {
  value = "${module.docker_cluster.swarm_managers}"
}

output "swarm_nodes" {
  value = "${module.docker_cluster.swarm_nodes}"
}