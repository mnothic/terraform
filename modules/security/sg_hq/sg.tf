
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

    // allow know networks
    ingress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = [
          "0.0.0.0/0",
        ]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    lifecycle {
      create_before_destroy = true
    }
}

output "sg_id" {
  value = "${aws_security_group.security_group.id}"
}
