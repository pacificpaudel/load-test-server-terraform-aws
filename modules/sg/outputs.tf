
output "sg_allow_http" {
  value = "${aws_security_group.allow_http.*.id}"
}

output "sg_allow_https" {
  value = "${aws_security_group.allow_https.*.id}"
}

output "sg_allow_ssh" {
  value = "${aws_security_group.allow_ssh.*.id}"
}

output "sg_allow_ssh_4422" {
  value = "${aws_security_group.allow_ssh_4422.*.id}"
}

output "sg_allow_ssh_4422_bastion" {
  value = "${aws_security_group.allow_ssh_4422_bastion.*.id}"
}

# output "sg_allow_ssh_4422_dt_bastion" {
#   value = "${aws_security_group.allow_ssh_4422_dt_bastion.*.id}"
# }

output "sg_allow_private_sql" {
  value = "${aws_security_group.allow_private_sql.*.id}"
}
output "sg_allow_private_redis" {
  value = "${aws_security_group.allow_private_redis.*.id}"
}
output "sg_allow_efs" {
  value = "${aws_security_group.allow_efs.*.id}"
}

output "sg_allow_zabbix_from_fiare_zabbix_server" {
	value = "${aws_security_group.allow_zabbix_from_fiare_zabbix_server.*.id}"
}
output "sg_allow_zabbix_from_bastion" {
	value = "${aws_security_group.allow_zabbix_from_bastion.*.id}"
}