
#Load test servers


resource "aws_instance" "loadtest-server" {

    ami = "ami-ae72f2dd"    
    instance_type = "m5.xlarge"
    ebs_optimized = true
    monitoring = "true"
    subnet_id = "${element(module.production_vpc.private_subnets, count.index)}"
     vpc_security_group_ids = [
         "${module.production_sg.sg_allow_ssh}",
         "${module.production_sg.sg_allow_http}",
         "${module.production_sg.sg_allow_https}",
         "${module.production_sg.sg_allow_efs}",
     ]
    associate_public_ip_address = false
    iam_instance_profile = "${aws_iam_instance_profile.ec2_assume_role.id}"
    key_name = "loadtest-keys"
    tags {
        Name = "Loadtest-server-${count.index+1}"
        Billing = "loadtest"
    }

    root_block_device {
        volume_size = 10
        delete_on_termination = true
    }
    user_data = <<EOF
#!/bin/bash

sudo su
echo -e "\nPort 22" >> /etc/ssh/sshd_config
service sshd restart
yum update -y
yum install java-1.8.0-openjdk-src.x86_64
yum install java-1.8.0-openjdk-headless.x86_64
yum install wget
wget https://www.nic.funet.fi/pub/mirrors/apache.org//jmeter/binaries/apache-jmeter-5.4.1.tgz
tar -xf apache-jmeter-5.4.1.tgz
cd /apache-jmeter-5.4.1/bin
./jmeter.sh
EOF
}
