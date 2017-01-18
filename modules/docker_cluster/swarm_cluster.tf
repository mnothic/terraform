variable "ami"                   { default = "ami-fbdf4b88" }
variable "vol_size"              { default = 8 }
variable "vol_type"              { default = "gp2" }
variable "tag_manager_name"      { defafult = "swarm-manager" }
variable "tag_node_name"         { defafult = "swarm-node" }
variable "tag_env"               { }
variable "tag_stack"             { }
variable "tag_type"              { }
variable "vpc_sg_ids"            { }
variable "key_name"              { default = "JKEY" }
variable "az"                    { }
variable "subnet_id"             { }
variable "code_name"             { }
variable "manager_instance_type" { default = "t2.small" }
variable "node_instance_type"    { default = "t2.small" }
variable "swarm_manager_count"   { default = 1 }
variable "swarm_node_count"      { default = 3 }
variable "private_key"           { default = "id_rsa" }
variable "provision_user"        { default = "ubuntu" }

resource "aws_iam_instance_profile" "ec2_instance" {
  name  = "ec2_instance_${var.code_name}"
  path  = "/"
  roles = ["ec2_instance_${var.code_name}"]
}

resource "aws_iam_role" "ec2_instance" {
  name               = "ec2_instance_${var.code_name}"
  path               = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_instance" "swarm-manager" {
  ami                         = "${var.ami}"
  availability_zone           = "${var.az}"
  ebs_optimized               = false
  instance_type               = "${var.manager_instance_type}"
  monitoring                  = false
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${split(",",var.vpc_sg_ids)}"]
  associate_public_ip_address = true
  source_dest_check           = true
  iam_instance_profile        = "${aws_iam_instance_profile.ec2_instance.name}"
  count                       = "${var.swarm_manager_count}"

  connection {
    user = "${var.provision_user}"
    private_key = "${file(concat("~/.ssh/", ${var.private_key}))}"
    agent = false
  }

  tags {
    Name = "manager-${count.index}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker swarm init"
    ]
  }

}

resource "aws_instance" "swarm-node" {
  ami                         = "${var.ami}"
  availability_zone           = "${var.az}"
  ebs_optimized               = false
  instance_type               = "${var.swarm_node_count}"
  monitoring                  = false
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${split(",",var.vpc_sg_ids)}"]
  associate_public_ip_address = true
  source_dest_check           = true
  iam_instance_profile        = "${aws_iam_instance_profile.ec2_instance.name}"
  count                       = "${var.swarm_node_count}"

  connection {
    user = "${var.provision_user}"
    private_key = "${file(concat("~/.ssh/", ${var.private_key}))}"
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join ${aws_instance.swarm-manager.0.private_ip}:2377 --token $(docker -H ${aws_instance.swarm-manager.0.private_ip} swarm join-token -q worker)"
    ]
  }

  depends_on = [
    "aws_instance.swarm-manager"
  ]
}

resource "null_resource" "cluster" {
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.swarm-node.*.id)}"
  }

  connection {
    host = "${aws_instance.swarm-manager.0.public_dns}"
    user = "${var.provision_user}"
    private_key = "${file(concat("~/.ssh/", ${var.private_key}))}"
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "docker network create --driver overlay appnet",
      "docker service create --name gunicorn --mode global --publish 80:8000 --network appnet gunicorn"
    ]
  }
}

output "swarm_managers" {
  value = "${concat(aws_instance.swarm-manager.*.public_dns)}"
}

output "swarm_nodes" {
  value = "${concat(aws_instance.swarm-node.*.public_dns)}"
}