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
  region = "us-east-1"
}

variable "domains" {
  type	= "list"
  default = ["lb2-dm", "app2-dm"]
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

resource "aws_security_group" "dm_zone" {
  name = "dm_zone"
}

resource "aws_security_group_rule" "allow_icmp_out" {
  type            = "egress"
from_port = -1
to_port = -1
protocol = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
 security_group_id = "${aws_security_group.dm_zone.id}"
}

resource "aws_security_group_rule" "allow_icmp_in" {
  type            = "ingress"
from_port = -1
to_port = -1
protocol = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
 security_group_id = "${aws_security_group.dm_zone.id}"
}

resource "aws_instance" "devdz" {
count= 2
ami = "ami-0ac019f4fcb7cb7e6"
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


resource "local_file" "ansible_inventory" {
    content     = "[web]\n${element(var.domains, 0)}.devops.srwx.net ansible_ssh_user=ubuntu  letsencrypt_email=denergym@mail.ru  domain_name1=${element(var.domains, 0)}.devops.srwx.net domain_name2=${element(var.domains, 1)}.devops.srwx.net \n[api]\n${element(var.domains, 1)}.devops.srwx.net ansible_ssh_user=ubuntu"
     filename = "inventory/calc"
}

resource "null_resource" "deploy" {
 
 provisioner "local-exec" {
    command = "ansible-playbook -i inventory/calc --private-key ${var.ssh_key_path} pre.yml"
  }


  provisioner "local-exec" {
    command = "ansible-playbook -i inventory/calc --private-key ${var.ssh_key_path} front.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i inventory/calc --private-key ${var.ssh_key_path} back.yml"
 
 }
}
