variable "cluster_name" { }
variable "db_name"      { }
variable "user"         { }
variable "pass"         { }
variable "az"           { }
variable "sg_ids"       { }
variable "eip"          { }
variable "subnet_ids"   { }
variable "node_type"    {
  default  = "dc1.large"
}

resource "aws_redshift_cluster" "redshift" {
  cluster_identifier                  = "${var.cluster_name}"
  database_name                       = "${var.db_name}"
  cluster_type                        = "single-node"
  node_type                           = "${var.node_type}"
  master_password                     = "${var.pass}"
  master_username                     = "${var.user}"
  availability_zone                   = "${var.az}"
  preferred_maintenance_window        = "fri:06:30-fri:07:00"
  cluster_parameter_group_name        = "default.redshift-1.0"
  automated_snapshot_retention_period = "1"
  port                                = "5439"
  cluster_version                     = "1.0"
  allow_version_upgrade               = "true"
  number_of_nodes                     = "1"
  publicly_accessible                 = "true"
  encrypted                           = "false"
  elastic_ip                          = "${var.eip}"
  skip_final_snapshot                 = "true"
  vpc_security_group_ids              = ["${split(",", var.sg_ids)}"]
  cluster_subnet_group_name           = "${aws_redshift_subnet_group.subnet_group.name}"
}

resource aws_redshift_subnet_group "subnet_group" {
  name        = "redshift"
  description = "redshift subnet group"
  subnet_ids  = ["${split(",", var.subnet_ids)}"]
}
output "endpoint" { value = "${aws_redshift_cluster.redshift.endpoint}" }
