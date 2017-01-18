variable "environment"  {}
variable "domain"       {}
variable "region"       {}
variable "public_cidr"  {
  default = "0.0.0.0/0"
}

variable "aws_account_id" {
  default = "527125839795"
}

variable "s3_backend" {
  default = "terraform-db"
}

provider "aws" {
  region = "${var.region}"
}

output "domain" {
  value = "${var.domain}"
}
