
terraform {
  required_version = "0.12.29"
}

provider "aws" {
    region     = "eu-west-1"
    version = "2.30"
}

########################
# Common security groups
########################
resource "aws_security_group" "allow_http" {
  count = "${var.create_allow_http}"

  vpc_id = "${var.vpc_id}"
  name = "Allow HTTP traffic"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "HTTP Security Group"
    Billing = "${var.billing}"
  }
}

resource "aws_security_group" "allow_https" {
  count = "${var.create_allow_https}"

  vpc_id = "${var.vpc_id}"
  name = "Allow HTTPS traffic"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"  
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "HTTPS Security Group"
    Billing = "${var.billing}"
  }
}

resource "aws_security_group" "allow_ssh" {
  count = "${var.create_allow_ssh}"

  vpc_id = "${var.vpc_id}"
  name = "Allow SSH traffic"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "SSH Security Group"
    Billing = "${var.billing}"
  }
}

resource "aws_security_group" "allow_efs" {
  count = "${var.create_allow_efs}"

  vpc_id = "${var.vpc_id}"
  name = "Allow EFS"
  
  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "EFS Security Group"
    Billing = "${var.billing}"
  }
}
