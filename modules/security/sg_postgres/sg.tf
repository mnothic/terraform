
variable "sg_name" {
  description = "The name for the security group"
}

variable "vpc_id" {
  description = "The VPC this security group will go in"
}

variable "source_sg" {
  description = "The source CIDR block to allow traffic from"
  type = "list"
}

variable "source_cidr" {
  description = "The source CIDR block to allow traffic from"
  type = "list"
}

resource "aws_security_group" "security_group" {
    name = "${var.sg_name}"
    description = "Security Group ${var.sg_name}"
    vpc_id = "${var.vpc_id}"

    // allow traffic for TCP 5432
    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        // these two are already a list, but I have to force it, bug?
        security_groups = ["${var.source_sg}"]
        cidr_blocks = ["${var.source_cidr}"]
    }
}

output "sg_id" {
  value = "${aws_security_group.security_group.id}"
}
