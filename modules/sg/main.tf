
terraform {
  required_version = "0.11.13"
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

resource "aws_security_group" "allow_ssh_4422" {
  count = "${var.create_allow_ssh_4422}"

  vpc_id = "${var.vpc_id}"
  name = "Allow SSH 4422"

  ingress {
    from_port = 4422
    to_port = 4422
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
    Name = "SSH 4422 Security Group"
    Billing = "${var.billing}"
  }
}

resource "aws_security_group" "allow_ssh_4422_bastion" {
  count = "${var.create_allow_ssh_4422_bastion}"

  vpc_id = "${var.vpc_id}"
  name = "Allow SSH 4422 from bastion"

  ingress {
    from_port = 4422
    to_port = 4422
    protocol = "tcp"
    cidr_blocks = ["${var.bastion_cidr}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.bastion_cidr}"]
  }
  tags {
    Name = "SSH 4422 Security Group from bastion"
    Billing = "${var.billing}"
  }
}

# resource "aws_security_group" "allow_ssh_4422_dt_bastion" {
#   count = "${var.create_allow_ssh_4422_bastion}"

#   vpc_id = "${var.vpc_id}"
#   name = "Allow SSH 4422 from Digitehtavat bastion"

#   ingress {
#     from_port = 4422
#     to_port = 4422
#     protocol = "tcp"
#     cidr_blocks = ["${var.dt_bastion_cidr}"]
#   }
#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["${var.dt_bastion_cidr}"]
#   }
#   tags {
#     Name = "SSH 4422 Security Group from Digitehtavat bastion"
#     Billing = "${var.billing}"
#   }
# }

resource "aws_security_group" "allow_private_sql" {
  count = "${var.create_allow_private_sql}"

  vpc_id = "${var.vpc_id}"
  name = "Allow Private SQL"

  ingress {
    from_port = 3306
    to_port = 3306
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
    Name = "Private SQL Security Group"
    Billing = "${var.billing}"
  }
}

resource "aws_security_group" "allow_private_redis" {
  count = "${var.create_allow_private_redis}"

  vpc_id = "${var.vpc_id}"
  name = "Allow Private Redis"
  
  ingress {
    from_port = 6379
    to_port = 6379
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
    Name = "Private Redis Security Group"
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

resource "aws_security_group" "allow_zabbix_from_fiare_zabbix_server" {
  count = "${var.create_allow_zabbix_from_fiare_zabbix_server}"

  vpc_id = "${var.vpc_id}"
  name = "Allow Zabbix connections from Fiare Zabbix server"

  ingress {
    from_port = 10051
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["94.237.29.143/32"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "Zabbix Security Group"
    Billing = "${var.billing}"
  }
}

resource "aws_security_group" "allow_zabbix_from_bastion" {
  count = "${var.create_allow_zabbix_from_bastion}"

  vpc_id = "${var.vpc_id}"
  name = "Allow Zabbix connections from bastion host"

  ingress {
    from_port = 10050
    to_port = 10050
    protocol = "tcp"
    cidr_blocks = ["10.7.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "Zabbix From Bastion Security Group"
    Billing = "${var.billing}"
  }
}