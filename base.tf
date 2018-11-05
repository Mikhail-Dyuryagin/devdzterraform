variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "ssh_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "zone_id" {
  type = "string"
  default = "ZUYOKXBWM9MWO"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "us-east-2"
}

variable "domains" {
  type  = "list"
  default = ["front-lb", "back-app"]
}

resource "random_string" "password" {
  count = "${length(var.domains)}"
  length = "14"
  upper   = true
  lower   = true
  number  = true
  special = false
}

resource "aws_key_pair" "mykey" {
  key_name = "mykey"
  public_key = "${file("${var.ssh_key_path}")}"
}


resource "aws_instance" "devdz" {
count= 2
ami = "ami-0f65671a86f061fcd"
instance_type = "t2.micro"
key_name= "mykey"
security_groups = ["${aws_security_group.dm_zone.name}"]
tags { Name="${element(var.domains, count.index)}.devops.srwx.net"}

}


resource "aws_route53_record" "devops_fall_dns" {
  count   = "${length(var.domains)}"
  zone_id = "${var.zone_id}"
  name  = "${element(var.domains, count.index)}.devops.srwx.net"
  type  = "A"
  ttl= "300"
  records = ["${element(aws_instance.devdz.*.public_ip, count.index)}"]
}
