
###########
# Override!
###########

variable "vpc_id" {
  description = "To which VPC the resources created to"
  default = ""
}

variable "billing" {
  description = "Name used for Billing tag on all resources"
  default = "load-test"
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


variable "create_allow_efs" {
  default = false
}

variable "cidr" {
  description = "Used for private security groups"
  default = "0.0.0.0/0"
}
