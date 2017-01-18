
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

    // allows traffic from the SG itself for tcp
    ingress {
        from_port = 0
        to_port   = 65535
        protocol  = "tcp"
        self      = true
    }

    // allows traffic from the SG itself for udp
    ingress {
        from_port = 0
        to_port   = 65535
        protocol  = "udp"
        self      = true
    }

    // allow traffic for TCP 3306
    ingress {
        from_port   = 5439
        to_port     = 5439
        protocol    = "tcp"
        cidr_blocks = ["${split(",",var.source_cidr_block)}"]
    }

}

output "sg_id" {
  value = "${aws_security_group.security_group.id}"
}
