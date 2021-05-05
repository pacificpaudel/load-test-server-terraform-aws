
resource "aws_security_group" "health_check" {
  vpc_id = "${module.production_vpc.vpc_id}"
  name = "Allow Health Check range"

  ingress {
    from_port = 30000
    to_port = 35000
    protocol = "tcp"  
    cidr_blocks = ["${module.production_vpc.vpc_cidr}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "Health Check Range Security Group"
    Billing = "Otava"
  }
}