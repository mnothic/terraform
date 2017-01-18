variable "backend_http_port" {
  description = "The backend port to which ELB http port is forwarded"
  default     = 81
}

variable "backend_https_port" {
  description = "The backend port to which ELB https port is forwarded"
  default     = 80
}

variable "country" {
  description = "The tag 'country' value for ELB"
}

variable "elb_internal" {
  description = "If the elb is internal"
  default     = "false"
}

variable "healthcheck_path" {
  description = "The ELB http health check url path (including first '/')"
  default     = "/health"
}

variable "healthcheck_port" {
  description = "The ELB http health check port"
  default     = 8080
}

variable "subnet_ids" {
  description = "The subnets where ELB is attached"
  type        = "list"
}

variable "project" {
  description = "The tag 'project' value for ELB"
}

variable "sg_trusted_id" {
  description = "The trusted security group id attached to ELB"
}

variable "ssl_cert_arn" {
  description = "The ARN of the SSL cert for ELB"
}

resource "aws_elb" "elb" {
  name                        = "${var.country}-${var.project}"
  subnets                     = ["${var.subnet_ids}"]
  security_groups             = ["${module.sg_elb.sg_id}", "${var.sg_trusted_id}"]
  cross_zone_load_balancing   = false
  idle_timeout                = 300
  connection_draining         = true
  connection_draining_timeout = 60
  internal                    = "${var.elb_internal}"

  listener {
    instance_port             = "${var.backend_http_port}"
    instance_protocol         = "http"
    lb_port                   = 80
    lb_protocol               = "http"
    ssl_certificate_id        = ""
  }

  listener {
    instance_port             = "${var.backend_https_port}"
    instance_protocol         = "http"
    lb_port                   = 443
    lb_protocol               = "https"
    ssl_certificate_id        = "${var.ssl_cert_arn}"
  }

  health_check {
    healthy_threshold         = 2
    unhealthy_threshold       = 9
    interval                  = 10
    target                    = "HTTP:${var.healthcheck_port}${var.healthcheck_path}"
    timeout                   = 5
  }

  tags {
    "country"                 = "${var.country}"
    "project"                 = "${var.project}"
    "Name"                    = "${var.country}-${var.project}"
  }
}

output "dns_name" {
  value                       = "${aws_elb.elb.dns_name}"
}
