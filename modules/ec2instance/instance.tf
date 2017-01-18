variable "ami"                  { default = "ami-907e33e3" }
variable "vol_size"             { default = 8 }
variable "vol_type"             { default = "gp2" }
variable "tag_name"             { }
variable "tag_env"              { }
variable "tag_stack"            { }
variable "tag_type"             { }
variable "vpc_sg_ids"           { }
variable "key_name"             { default = "default_key" }
variable "instance_type"        { default = "t2.small" }
variable "az"                   { }
variable "subnet_id"            { }

resource "aws_instance" "instance" {
  ami                         = "${var.ami}"
  availability_zone           = "${var.az}"
  ebs_optimized               = false
  instance_type               = "${var.instance_type}"
  monitoring                  = false
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${split(",",var.vpc_sg_ids)}"]
  associate_public_ip_address = true
  source_dest_check           = true
  iam_instance_profile        = "${aws_iam_instance_profile.ec2_instance.name}"

  root_block_device {
    volume_type           = "${var.vol_type}"
    volume_size           = "${var.vol_size}"
    delete_on_termination = true
  }

  tags {
    "Name"             = "${var.tag_name}"
    "env"              = "${var.tag_env}"
    "stack"            = "${var.tag_stack}"
    "type"             = "${var.tag_type}"
  }
}

output "publicip" {
  value = "${aws_instance.instance.public_ip}"
}
