
###########
# Override!
###########

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default = "load-test"
}

variable "billing" {
  description = "Name used for Billing tag on all resources"
  default = "load-test"
}

variable "cidr" {
  default = "0.0.0.0/0"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  default = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  default = []
}

variable "azs" {
  description = "A list of availability zones in the region"
  default = []
}

##########
# Optional
##########

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  default = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default = {}
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  default = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  default = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  default = {}
}

variable "public_route_table_tags" {
  description = "Additional tags for the private subnets"
  default = {}
}

variable "private_route_table_tags" {
  description = "Additional tags for the private subnets"
  default = {}
}

variable "create_nat" {
  description = "Create NAT on public subnet 0 if set to true"
  default = false
}