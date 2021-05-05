# Tags resources
all_tags = [
    "Ubuntu-Server",   #0
    "Developer",       #1
    "Moises Tapia",    #2
    "public_sg",       #3
    "public_vpc",      #4
    "public_intgaw",   #5
    "public_subnet",   #6
    "public_routet",   #7
    "public_ebs",      #8
    "/dev/sdh"         #9
]

# Provider
aws_region  = "us-east-2"

# Instance
aws_ami         = "ami-0bbe28eb2173f6167"
aws_insta_type  = "t2.micro"

# Security_Group
aws_public_sec_ingress = [22, 80, 4444, 8080]
aws_public_sec_egress  = [22, 80, 4444, 8080]
protocol_net           = "tcp"

# Networking
aws_networking  = [
    "10.0.0.0/16",
    "10.0.1.0/24",
    "0.0.0.0/0"
] 