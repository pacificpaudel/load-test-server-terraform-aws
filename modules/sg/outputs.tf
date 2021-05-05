
output "sg_allow_http" {
  value = "${aws_security_group.allow_http.*.id}"
}

output "sg_allow_https" {
  value = "${aws_security_group.allow_https.*.id}"
}

output "sg_allow_ssh" {
  value = "${aws_security_group.allow_ssh.*.id}"
}


output "sg_allow_efs" {
  value = "${aws_security_group.allow_efs.*.id}"
}
