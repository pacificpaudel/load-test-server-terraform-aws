
terraform {
  required_version = "0.12.29"
}

provider "aws" {
    region     = "eu-west-1"
    version = "2.30"
}

locals {
  subnet_number = [1, 2, 3, 4, 5, 6, 7, 8, 9]
}

#####
# VPC
#####
resource "aws_vpc" "this" {
  cidr_block = "${var.cidr}"
  enable_dns_hostnames = "true"
  
  tags = "${merge(
    var.tags, 
    var.vpc_tags, 
    map("Name", format("%s VPC", var.name)), 
    map("Billing", format("%s", var.billing))
  )}"
}

##################
# Internet Gateway
##################
resource "aws_internet_gateway" "this" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(
    var.tags, 
    map("Name", format("%s Internet Gateway", var.name)),
    map("Billing", format("%s", var.billing))
  )}"
}

###########################
# Public subnets and routes
###########################
resource "aws_subnet" "public" {
  count = "${length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  vpc_id = "${aws_vpc.this.id}"
  cidr_block = "${var.public_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(
    var.tags, 
    var.public_subnet_tags, 
    map("Name", format("%s Public Subnet %s", var.name, element(local.subnet_number, count.index))),
    map("Billing", format("%s", var.billing))
  )}"
}

resource "aws_route_table" "public" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(
    var.tags, 
    var.public_route_table_tags, map("Name", format("%s Public Route", var.name)),
    map("Billing", format("%s", var.billing))
  )}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route" "public_internet_gateway" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

############################
# Private subnets and routes
############################
resource "aws_subnet" "private" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  vpc_id = "${aws_vpc.this.id}"
  cidr_block = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(
    var.tags, 
    var.private_subnet_tags, 
    map("Name", format("%s Private Subnet %s", var.name, element(local.subnet_number, count.index))),
    map("Billing", format("%s", var.billing))
  )}"
}

resource "aws_route_table" "private" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  vpc_id = "${aws_vpc.this.id}"

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = ["propagating_vgws"]
  }

  tags = "${merge(
    var.tags, 
    var.private_route_table_tags, 
    map("Name", format("%s Private Route %s", var.name, element(local.subnet_number, count.index))),
    map("Billing", format("%s", var.billing))
  )}"
}

resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 1}"

  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

#####
# NAT
#####
resource "aws_eip" "nat" {
  count = "${var.create_nat && length(var.public_subnets) > 0 ? 1 : 1}"

  vpc = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_nat_gateway" "this" {
  #count = "${var.create_nat && length(var.public_subnets) > 0 ? 0 : 1}"

  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${element(aws_subnet.public.*.id, 0)}"
  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route" "nat" {
  count = "${var.create_nat && length(var.private_subnets) > 0 ? length(var.private_subnets) : 1}"

  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.this.id}"
}