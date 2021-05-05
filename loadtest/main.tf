terraform {
    backend "s3" {
        bucket = "fiare-otava-tf"
        region = "eu-west-1"
        key = "otava-env-terraform.tfstate"
        dynamodb_table = "tf-state-lock"

    }
}

provider "aws" {
    region = "eu-west-1"
    version = "2.30"
}

module "production_vpc" {
  source = "../tfmodules/vpc/"
  name = "loadtest"
  billing = "loadtest"

  cidr = "10.7.0.0/16"
  azs = ["eu-west-1a"]
  public_subnets = ["10.7.1.0/24"]
  private_subnets = ["10.7.4.0/24"]
  create_nat = true
}

module "production_sg" {
  source = "../tfmodules/sg/"
  billing = "loadtest"
  vpc_id = "${module.production_vpc.vpc_id}"

  create_allow_http = true
  create_allow_https = true
  create_allow_ssh_4422 = true
  create_allow_ssh_4422_bastion = true
  create_allow_private_sql = true
  create_allow_efs = true
  create_allow_zabbix_from_fiare_zabbix_server = true
  create_allow_zabbix_from_bastion = true
  cidr = "${module.production_vpc.vpc_cidr}"
}

resource "aws_iam_policy" "force_mfa_prod" {
  name = "Force_MFA_Prod"
  path = "/"
  policy = "${var.allow_password_change_without_mfa ? data.aws_iam_policy_document.force_mfa_but_allow_sign_in_to_change_password.json : data.aws_iam_policy_document.force_mfa.json }"
}

resource "aws_iam_group_policy_attachment" "assign_force_mfa_policy_to_groups" {
  count = "${length(var.groups)}"
  group      = "${element(var.groups, count.index)}"
  policy_arn = "${aws_iam_policy.force_mfa_prod.arn}"
}

resource "aws_iam_user_policy_attachment" "assign_force_mfa_policy_to_users" {
  count = "${length(var.users)}"
  user  = "${element(var.users, count.index)}"
  policy_arn = "${aws_iam_policy.force_mfa_prod.arn}"
}

#Route for VPC Peering connection (From bastion to Digikoe-VPC)

resource "aws_route" "vpc_peering_bastion_route" {
  route_table_id            = "${element(module.production_vpc.public_route_table, count.index)}"
  destination_cidr_block    = "10.8.0.0/16"
  vpc_peering_connection_id = "pcx-0d09bd4d8863fae90"
}