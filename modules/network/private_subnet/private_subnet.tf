#--------------------------------------------------------------
# This module creates all resources necessary for a private
# subnet
#--------------------------------------------------------------

variable "name"            {
  default = "private"
}
variable "vpc_id"          {}
variable "cidrs"           {
  type    = "list"
}
variable "azs"             {}
variable "nat_gateway_ids" {
  default = []
  type    = "list"
}

resource "aws_subnet" "private" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.cidrs, count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(var.cidrs)}"

  tags      { Name = "${var.name}.${element(split(",", var.azs), count.index)}" }
  lifecycle { create_before_destroy = true }
}

resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"
  count  = "${length(var.cidrs)}"

/* we do not use it
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(var.nat_gateway_ids, count.index)}"
  }
*/

  tags      { Name = "${var.name}.${element(split(",", var.azs), count.index)}" }
  lifecycle { create_before_destroy = true }
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.cidrs)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

  lifecycle { create_before_destroy = true }
}

output "subnet_ids" { value = ["${aws_subnet.private.*.id}"] }
