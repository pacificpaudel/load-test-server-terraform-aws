
###########
# Override!
###########

variable "vpc_id" {
  description = "To which VPC the resources created to"
  default = ""
}

variable "billing" {
  description = "Name used for Billing tag on all resources"
  default = ""
}

##########
# Optional
##########

variable "create_allow_http" {
  default = false
}

variable "create_allow_https" {
  default = false
}

variable "create_allow_ssh" {
  default = false
}

variable "create_allow_ssh_4422" {
  default = false
}

variable "create_allow_ssh_4422_bastion" {
  default = false
}

variable "create_allow_private_sql" {
  default = false
}

variable "create_allow_private_redis" {
  default = false
}

variable "create_allow_ssh_4422_dt_bastion" {
  default = false
}

variable "create_allow_efs" {
  default = false
}

variable "cidr" {
  description = "Used for private security groups"
  default = "0.0.0.0/0"
}

variable "bastion_cidr" {
  description = "Used for bastion security group"
  default = "10.7.1.0/24"
}

# variable "dt_bastion_cidr" {
#   description = "Used for bastion security group"
#   default = "10.7.1.0/24"
# }

variable "create_allow_zabbix_from_fiare_zabbix_server" {
  description = "Allow Zabbix connections from zabbix.fiare.com server"
  default = false
}
variable "create_allow_zabbix_from_bastion" {
  description = "Allow Zabbix connections from bastion host"
  default = false
}