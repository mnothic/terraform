
variable "sg_name" {
  description = "The name for the security group"
}

variable "vpc_id" {
  description = "The VPC this security group will go in"
}

variable "source_cidr_block" {
  description = "The source CIDR block to allow traffic from"
}
resource "aws_security_group" "security_group" {
    name = "${var.sg_name}"
    description = "Security Group ${var.sg_name}"
    vpc_id = "${var.vpc_id}"

  ingress {
      from_port   = 2375
      to_port     = 2377
      protocol    = "tcp"
      cidr_blocks = ["${split(",",var.source_cidr_block)}"]
  }

  ingress {
      from_port   = 7946
      to_port     = 7946
      protocol    = "tcp"
      cidr_blocks = ["${split(",",var.source_cidr_block)}"]
  }

  ingress {
      from_port   = 7946
      to_port     = 7946
      protocol    = "udp"
      cidr_blocks = ["${split(",",var.source_cidr_block)}"]
  }

  ingress {
      from_port   = 4789
      to_port     = 4789
      protocol    = "tcp"
      cidr_blocks = ["${split(",",var.source_cidr_block)}"]
  }

  ingress {
      from_port   = 4789
      to_port     = 4789
      protocol    = "udp"
      cidr_blocks = ["${split(",",var.source_cidr_block)}"]
  }

  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  }

  ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  }

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  }

}

output "sg_id" {
  value = "${aws_security_group.security_group.id}"
}
