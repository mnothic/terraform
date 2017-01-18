module "instance_role" {
  source  = "../iam_instance_profile"
  country = "${var.country}"
  project = "${var.project}"
}

resource "aws_iam_policy" "policy" {
  name = "Ofertia${upper(var.country)}${var.project}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        ${file("${path.root}/../files/iam_policy_privaterepo")},
        ${file("${path.root}/../files/iam_policy_cloudwatchlogs")},
        ${file("${path.root}/../files/iam_policy_cloudwatchcustommetrics")}
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "policy_attachment" {
  name       = "${var.project}-attachment"
  roles      = ["${module.instance_role.role_name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}

output "instance_role" {
  value = "${module.instance_role.role_name}"
}
