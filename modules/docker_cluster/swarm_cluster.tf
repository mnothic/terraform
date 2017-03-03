variable "ami"                   { default = "" }
variable "m_vol_size"            { default = 8 }
variable "n_vol_size"            { default = 8 }
variable "vol_type"              { default = "gp2" }
variable "tag_manager_name"      { default = "swarm-manager" }
variable "tag_node_name"         { default = "swarm-node" }
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
variable "private_key"           { default = "~/.ssh/id_rsa" }
variable "provision_user"        { default = "ubuntu" }

resource "aws_iam_instance_profile" "ec2_instance" {
  name  = "ec2_${var.code_name}"
  path  = "/"
  roles = ["ec2_${var.code_name}"]
}

resource "aws_iam_role" "ec2_instance" {
  name               = "ec2_${var.code_name}"
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
  master                      = "sudo docker swarm init"
  slave                       = "docker swarm --manager join ${aws_instance.swarm-manager.0.private_ip}:2377 --token $(docker -H ${aws_instance.swarm-manager.0.private_ip} swarm join-token -q worker)"
  root_block_device {
    volume_type           = "${var.vol_type}"
    volume_size           = "${var.m_vol_size}"
    delete_on_termination = true
  }

  connection {
    user        = "${var.provision_user}"
    private_key = "${file(var.private_key)}"
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "${count.index == 0 ? var.master : var.slave}",
      "docker login -u mnothic -p ${file("~/.dockerhub")}"
    ]
  }

  tags {
    Name = "manager-${count.index}"
  }
}

resource "aws_instance" "swarm-node" {
  ami                         = "${var.ami}"
  availability_zone           = "${var.az}"
  ebs_optimized               = false
  instance_type               = "${var.node_instance_type}"
  monitoring                  = false
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${split(",",var.vpc_sg_ids)}"]
  associate_public_ip_address = true
  source_dest_check           = true
  iam_instance_profile        = "${aws_iam_instance_profile.ec2_instance.name}"
  count                       = "${var.swarm_node_count}"

  root_block_device {
    volume_type           = "${var.vol_type}"
    volume_size           = "${var.n_vol_size}"
    delete_on_termination = true
  }
  connection {
    user = "${var.provision_user}"
    private_key = "${file(var.private_key)}"
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join ${aws_instance.swarm-manager.0.private_ip}:2377 --token $(docker -H ${aws_instance.swarm-manager.0.private_ip} swarm join-token -q worker)"
    ]
  }

  tags {
    Name = "node-${count.index}"
  }

  depends_on = [
    "aws_instance.swarm-manager"
  ]
}

resource "null_resource" "cluster" {
  triggers {
    cluster_instance_ids = "${aws_instance.swarm-manager.0.id}"
  }

  connection {
    host = "${aws_instance.swarm-manager.0.public_dns}"
    user = "${var.provision_user}"
    private_key = "${file(var.private_key)}"
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "docker network create --driver overlay appnet",
      "docker service create --name django --publish 80:8000 --with-registry-auth --network appnet mnothic/django",
      "docker service create --name=viz --publish=9000:8080/tcp --constraint=node.role==manager --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock manomarks/visualizer"
    ]
  }
}

output "swarm_managers" {
  value = "${concat(aws_instance.swarm-manager.*.public_ip)}"
}

output "swarm_nodes" {
  value = "${concat(aws_instance.swarm-node.*.public_ip)}"
}