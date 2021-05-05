
output "vpc_id" {
  value = "${aws_vpc.this.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.this.cidr_block}"
}

output "azs" {
   value = "${var.azs}"
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value = ["${aws_subnet.public.*.id}"]
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value = ["${aws_subnet.private.*.id}"]
}

output "nat_gateway_id" {
  value = "${aws_nat_gateway.this.*.id}"
}

output "public_route_table" {
  value = "${aws_route_table.public.*.id}"
}

output "private_route_tables" {
  value = ["${aws_route_table.private.*.id}"]
}