variable "code_name"       { default = "" }

resource "aws_iam_instance_profile" "ec2_instance" {
  name  = "ec2_${var.code_name}"
  path  = "/"
  roles = ["ec2_${var.code_name}"]
}

resource "aws_iam_role" "ec2_instance" {
  name               = "ec2_${var.code_name}"
  path               = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
