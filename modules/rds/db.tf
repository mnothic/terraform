variable "availability_zone" {
  description = "The RDS availability zone"
  default     = "eu-west-1b"
}

variable "instance_class" {
  description = "The instance class of RDS"
  default     = "db.r3.xlarge"
}

variable "public_instance" {
  description = "Control if instance is publicly accessible"
  default = "false"
}

variable "password" {
  description = "The admin password"
}

variable "skip_final_snapshot" {
  description = "If snapshot creation is skipped after deleting RDS"
  default     = "true"
}

variable "sg_trusted_id" {
  description = "The trusted security group id attached to RDS"
}

variable "username" {
  description = "The admin username"
}

variable "version" {
  description = "Version of the RDS engine"
  default     = "9.5.2"
}

variable "dbname" {
  description = "The DB name to create. If omitted, no database is created initially."
  default = ""
}

resource "aws_db_instance" "rds" {
  identifier                = "${var.name}"
  allocated_storage         = 500
  storage_type              = "gp2"
  engine                    = "postgres"
  engine_version            = "${var.version}"
  instance_class            = "${var.instance_class}"
  name                      = "${var.dbname}"
  username                  = "${var.username}"
  password                  = "${var.password}"
  port                      = 5432
  publicly_accessible       = "${var.public_instance}"
  availability_zone         = "${var.availability_zone}"
  vpc_security_group_ids    = ["${var.sg_trusted_id}","${module.sg_rds.sg_id}"]
  db_subnet_group_name      = "default-${var.vpc_id}"
  parameter_group_name      = "default.postgres9.5"
  multi_az                  = false
  backup_retention_period   = 1
  backup_window             = "00:26-00:56"
  maintenance_window        = "mon:23:04-mon:23:34"
  final_snapshot_identifier = "${var.name}-final"
  skip_final_snapshot       = "${var.skip_final_snapshot}"
  tags {
    Name    = "${var.name}"
    country = "${var.country}"
  }
}

output "rds_endpoint" {
  value = "${aws_db_instance.rds.endpoint}"
}
