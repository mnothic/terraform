
module "jenkins_ec2" {
  source               = "../modules/ec2instance"
  code_name            = "${var.vpc_name}_jenkins"
  ami                  = "ami-bb6b26c8"
  instance_type        = "c4.large"
  vol_size             = 8
  vol_type             = "gp2"
  tag_name             = "${var.env}-jenkins"
  tag_env              = "${var.env}"
  tag_stack            = "platform"
  tag_type             = "jenkins"
  vpc_sg_ids           = "${module.network.sg_hq_id}"
  key_name             = "JKEY"
  az                   = "${element(split(",",var.vpc_azs), 0)}"
  subnet_id            = "${element(split(",",module.network.public_subnet_ids), 0)}"
}

output "jenkins_ec2_ip" { value = "${module.jenkins_ec2.publicip}" }