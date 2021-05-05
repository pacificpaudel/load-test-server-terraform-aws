
output "vpc_id" {
  value = "${module.production_vpc.vpc_id}"
}

output "vpc_cidr" {
  value = "${module.production_vpc.vpc_cidr}"
}

output "public_subnets" {
  value = ["${module.production_vpc.public_subnets}"]
}

output "private_subnets" {
  value = ["${module.production_vpc.private_subnets}"]
}

output "azs" {
  value = ["${module.production_vpc.azs}"]
}

output "public_route_table" {
  value = "${module.production_vpc.public_route_table}"
}

output "private_route_tables" {
  value = ["${module.production_vpc.private_route_tables}"]
}

output "sg_allow_http" {
  value = "${module.production_sg.sg_allow_http}"
}

output "sg_allow_https" {
  value = "${module.production_sg.sg_allow_https}"
}

output "sg_allow_ssh" {
  value = "${module.production_sg.sg_allow_ssh}"
}

output "sg_allow_ssh_4422" {
  value = "${module.production_sg.sg_allow_ssh_4422}"
}

output "sg_allow_private_sql" {
  value = "${module.production_sg.sg_allow_private_sql}"
}

output "www_storage_dns_name" {
value = "${aws_efs_file_system.www-storage.dns_name}"
}

output "ec2_assume_role_id" {
  value = "${aws_iam_instance_profile.ec2_assume_role.id}"
}

#output "sg_allow_private_redis" {
#  value = "${module.production_sg.sg_allow_private_redis}"
#}

#output "cluster_id" {
#  value = "${module.production_ecs_cluster.cluster_id}"
#}