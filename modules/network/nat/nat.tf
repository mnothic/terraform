#--------------------------------------------------------------
# This module creates all resources necessary for NAT
#--------------------------------------------------------------

variable "name"               { default = "nat" }
variable "azs"                { }
variable "private_subnet_ids" { }

resource "aws_eip" "nat" {
  vpc   = true

  count = "${length(split(",", var.azs))}"

  lifecycle { create_before_destroy = true }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(split(",", var.private_subnet_ids), count.index)}"

  count = "${length(split(",", var.azs))}"

  lifecycle { create_before_destroy = true }
}

output "nat_gateway_ids" { value = "${join(",", aws_nat_gateway.nat.*.id)}" }
output "network_interface_ids" { value = "${join(",", aws_nat_gateway.nat.*.network_interface_id)}" }