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

