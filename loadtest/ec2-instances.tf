# Load balancer
module "production_alb" {
  source = "../tfmodules/alb/"
  name = "Otava alb"
  billing = "Otava"
  vpc_id = "${module.production_vpc.vpc_id}"

  security_groups = [
    "${module.production_sg.sg_allow_http}",
    "${module.production_sg.sg_allow_https}"
  ]
  subnets = ["${module.production_vpc.public_subnets}"]
}

#ALB 2
module "production_alb2" {
  source = "../tfmodules/alb/"
  name = "Otava alb2"
  billing = "Otava"
  vpc_id = "${module.production_vpc.vpc_id}"

  security_groups = [
    "${module.production_sg.sg_allow_http}",
    "${module.production_sg.sg_allow_https}"
  ]
  subnets = ["${module.production_vpc.public_subnets}"]
}

#Application servers


resource "aws_instance" "www1" {

    ami = "ami-08d658f84a6d84a80"    
    #instance_type = "c5.4xlarge"
    instance_type = "c5.4xlarge"
    ebs_optimized = true
    monitoring = "true"
    subnet_id = "${element(module.production_vpc.private_subnets, count.index)}"
     vpc_security_group_ids = [
         "${module.production_sg.sg_allow_ssh_4422_bastion}",
         "${module.production_sg.sg_allow_http}",
         "${module.production_sg.sg_allow_https}",
         "${module.production_sg.sg_allow_efs}",
         "${module.production_sg.sg_allow_zabbix_from_bastion}"
     ]
    associate_public_ip_address = false
    iam_instance_profile = "${aws_iam_instance_profile.ec2_assume_role.id}"
    key_name = "otava-key"
    tags {
        Name = "Otava new WWW Server ${count.index+1}"
        Billing = "Otava"
    }

    root_block_device {
        volume_size = 50
        delete_on_termination = false
    }
#     user_data = <<EOF
# #!/bin/bash
# echo -e "\nPort 4422" >> /etc/ssh/sshd_config
# sudo service sshd restart
# sudo apt-get update -y
# sudo git clone https://github.com/aws/efs-utils
# cd efs-utils
# sudo apt-get -y install binutils
# sudo ./build-deb.sh
# sudo apt-get -y install ./build/amazon-efs-utils*deb
# cd ..
# sudo mkdir /data
# echo ${aws_efs_file_system.www-storage.dns_name}:/  /data   nfs nfsvers=4.1,_netdev,rw,noatime,nodiratime,hard,actimeo=120,timeo=600,retrans=2,noresvport,rsize=1048576,wsize=1048576,intr,nolock   0 0 > /etc/fstab
# sudo mount -a
# EOF
}

resource "aws_instance" "www2" {

    ami = "ami-08d658f84a6d84a80"
    #instance_type = "c5.4xlarge"
    instance_type = "c5.4xlarge"
    monitoring = "true"
    subnet_id = "${element(module.production_vpc.private_subnets, count.index)}"
     vpc_security_group_ids = [
         "${module.production_sg.sg_allow_ssh_4422_bastion}",
         "${module.production_sg.sg_allow_http}",
         "${module.production_sg.sg_allow_https}",
         "${module.production_sg.sg_allow_efs}",
         "${module.production_sg.sg_allow_zabbix_from_bastion}"
     ]
    associate_public_ip_address = false
    iam_instance_profile = "${aws_iam_instance_profile.ec2_assume_role.id}"
    key_name = "otava-key"
    tags {
        Name = "Otava new WWW Server 2"
        Billing = "Otava"
    }

    root_block_device {
        volume_size = 50
        delete_on_termination = false
    }
    user_data = <<EOF
#!/bin/bash
echo -e "\nPort 4422" >> /etc/ssh/sshd_config
sudo service sshd restart
sudo apt-get update -y
sudo git clone https://github.com/aws/efs-utils
cd efs-utils
sudo apt-get -y install binutils
sudo ./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb
cd ..
sudo mkdir /data
echo ${aws_efs_file_system.www-storage.dns_name}:/  /data   nfs nfsvers=4.1,_netdev,rw,noatime,nodiratime,hard,actimeo=120,timeo=600,retrans=2,noresvport,rsize=1048576,wsize=1048576,intr,nolock   0 0 > /etc/fstab
sudo mount -a
sudo dpkg -i /var/advantlabs/installed-packages/oracle-java7-jdk_7u45_amd64.deb
sudo echo "deb http://nginx.org/packages/ubuntu/ bionic nginx" >> /etc/apt/sources.list.d/nginx.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
sudo apt-get -y update
sudo apt-get -y install nginx
sudo cp /var/advantlabs/installed-packages/nginx.conf /etc/nginx/nginx.conf
sudo ln -s /var/advantlabs/nginx /etc/nginx/advantlabs
sudo systemctl enable nginx.service
sudo systemctl start nginx
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
sudo usermod -a -G tomcat ubuntu
sudo cp /var/advantlabs/installed-packages/apache-tomcat-6.0.53.tar.gz /opt
cd /opt
sudo tar xvzf apache-tomcat-6.0.53.tar.gz
sudo mv apache-tomcat-6.0.53 tomcat
sudo chown -hR tomcat:tomcat tomcat
sudo chmod +x /opt/tomcat/bin/*
sudo cp /var/advantlabs/installed-packages/tomcat6.service /etc/systemd/system/tomcat6.service
sudo systemctl enable tomcat6.service
sudo systemctl start tomcat6
sudo echo -e "\nfs.file-max = 70000" >> /etc/sysctl.conf
sudo echo -e "\nnginx       soft    nofile   10000" >> /etc/security/limits.conf
sudo echo -e "\nnginx       hard    nofile   10000" >> /etc/security/limits.conf
sudo echo -e "\ntomcat      soft    nofile   10000" >> /etc/security/limits.conf
sudo echo -e "\ntomcat      hard    nofile   10000" >> /etc/security/limits.conf
sudo sysctl -p
EOF
}

#www1
resource "aws_lb_target_group_attachment" "www-tg1" {
  target_group_arn = "${module.production_alb.target_group_arn}"
  target_id        = "${aws_instance.www1.id}"
  port             = 80
}

#www2
resource "aws_lb_target_group_attachment" "www-tg2" {
  target_group_arn = "${module.production_alb2.target_group_arn}"
  target_id        = "${aws_instance.www2.id}"
  port             = 80
}


resource "aws_ebs_volume" "ebs_www1" {
  availability_zone = "${element(module.production_vpc.azs, count.index)}"
  #size=500
  size = 1000
  iops = 3000
  type = "io1"
  tags {
    Name = "www1-data"
    Billing = "Otava"
    Backup = "Yes"
  }
  lifecycle {
    prevent_destroy = true
  }   
}

resource "aws_ebs_volume" "ebs_www2" {
  availability_zone = "${element(module.production_vpc.azs, count.index)}"
  #size=500
  size = 1000
  iops = 3000
  type = "io1"
  tags {
    Name = "www2-data"
    Billing = "Otava"
    Backup = "Yes"
  }
  lifecycle {
    prevent_destroy = true
  }   
}


resource "aws_volume_attachment" "www_ebs" {
  
  device_name  = "/dev/sdi"
  volume_id    = "${aws_ebs_volume.ebs_www1.id}"
  instance_id  = "${aws_instance.www1.id}"
  force_detach = true
  #TODO - CHECK THIS - IS REBOOTING NEEDED? FOR SOME REASON ADDING SLEEP 10s, THIS WORKS
  provisioner "file" {
    source = "${var.infra_path}/bin/format-mount-ebs"
    destination = "/tmp/format-mount-ebs"
    connection {
      host = "${aws_instance.www2.private_ip}"
      user = "ubuntu"
      port = "4422"
      private_key = "${file("~/.ssh/otava-key.pem")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
      bastion_user = "ec2-user"
      bastion_port = "4422"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "bash /tmp/format-mount-ebs /dev/xvdi /var/advantlabs",
      "sudo chown 1000 /var/advantlabs"
    ]
    connection {
      host = "${aws_instance.www2.private_ip}"
      user = "ubuntu"
      port = "4422"
      private_key = "${file("~/.ssh/otava-key.pem")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
      bastion_user = "ec2-user"
      bastion_port = "4422"
    }
  }  
}

  
resource "aws_volume_attachment" "www2_ebs" {
  
  device_name  = "/dev/sdi"
  volume_id    = "${aws_ebs_volume.ebs_www2.id}"
  instance_id  = "${aws_instance.www2.id}"
  force_detach = true
  #TODO - CHECK THIS - IS REBOOTING NEEDED? FOR SOME REASON ADDING SLEEP 10s, THIS WORKS
  provisioner "file" {
    source = "${var.infra_path}/bin/format-mount-ebs"
    destination = "/tmp/format-mount-ebs"
    connection {
      host = "${aws_instance.www2.private_ip}"
      user = "ubuntu"
      port = "4422"
      private_key = "${file("~/.ssh/otava-key.pem")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
      bastion_user = "ec2-user"
      bastion_port = "4422"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "bash /tmp/format-mount-ebs /dev/xvdi /var/advantlabs",
      "sudo chown 1000 /var/advantlabs"
    ]
    connection {
      host = "${aws_instance.www2.private_ip}"
      user = "ubuntu"
      port = "4422"
      private_key = "${file("~/.ssh/otava-key.pem")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
      bastion_user = "ec2-user"
      bastion_port = "4422"
    }
  }  
}


#EFS Storage
resource "aws_efs_file_system" "www-storage" {
  creation_token = "otava-www-storage"
  tags {
    Name = "Otava www-storage"
    Billing = "Otava"
  }
}

resource "aws_efs_mount_target" "efs" {
  #Doesn't work
  #count           = "${length(module.production_vpc.public_subnets)}"
  count = "3"
  file_system_id  = "${aws_efs_file_system.www-storage.id}"
  subnet_id       = "${element(module.production_vpc.private_subnets, count.index)}"
  security_groups = [
        "${module.production_sg.sg_allow_efs}"
    ]
}

#Maintenance server

resource "aws_instance" "maintenance-server" {

    ami = "ami-08d658f84a6d84a80"
    instance_type = "t2.small"
    monitoring = "false"
    subnet_id = "${element(module.production_vpc.private_subnets, 0)}"
     vpc_security_group_ids = [
         "${module.production_sg.sg_allow_ssh_4422_bastion}",
         "${module.production_sg.sg_allow_http}",
         "${module.production_sg.sg_allow_https}",
         "${module.production_sg.sg_allow_efs}"
     ]
    associate_public_ip_address = false
    #iam_instance_profile = "${aws_iam_instance_profile.ec2_assume_role.id}"
    iam_instance_profile = "${aws_iam_instance_profile.snapshot-profile.id}"
    key_name = "otava-key"
    tags {
        Name = "Otava Maintenance Server"
        Billing = "Otava"
    }

    root_block_device {
        volume_size = 10
        delete_on_termination = true
    }
    user_data = <<EOF
#!/bin/bash
echo -e "\nPort 4422" >> /etc/ssh/sshd_config
sudo service sshd restart
sudo yum update -y
sudo yum install -y nc
sudo echo "deb http://nginx.org/packages/ubuntu/ bionic nginx" >> /etc/apt/sources.list.d/nginx.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
sudo apt-get -y update
sudo apt-get -y install nginx
sudo systemctl enable nginx.service
sudo systemctl start nginx
sudo mkdir -p /var/www
sudo sed -i 's/include \/etc\/nginx\/conf\.d\/\*\.conf;/include \/etc\/nginx\/maintenance\/\*\.conf;/' /etc/nginx/nginx.conf
sudo systemctl restart nginx
EOF
}

resource "aws_ebs_volume" "maintenance-disk" {
  availability_zone = "${element(module.production_vpc.azs, 0)}"
  size = 10
  type = "gp2"
  tags {
    Name = "Maintenance disk"
    Billing = "Otava"
  }
  lifecycle {
    prevent_destroy = false
  }   
}

resource "aws_volume_attachment" "maintenance-atchmt" {
  
  device_name  = "/dev/sdi"
  volume_id    = "${aws_ebs_volume.maintenance-disk.id}"
  instance_id  = "${aws_instance.maintenance-server.id}"
  force_detach = true
  #TODO - CHECK THIS - IS REBOOTING NEEDED? FOR SOME REASON ADDING SLEEP 10s, THIS WORKS
  provisioner "file" {
    source = "${var.infra_path}/bin/format-mount-ebs"
    destination = "/tmp/format-mount-ebs"
    connection {
      host = "${aws_instance.maintenance-server.private_ip}"
      user = "ubuntu"
      port = "4422"
      private_key = "${file("~/.ssh/otava-key.pem")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
      bastion_user = "ec2-user"
      bastion_port = "4422"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "bash /tmp/format-mount-ebs /dev/xvdi /var/www",
      "sudo chown 1000 /var/www",
      "sudo mkdir -p /var/www/html",
      "sudo mkdir -p /var/www/nginx/confs",
      "sudo ln -s /var/www/nginx/confs /etc/nginx/maintenance",
      "pwd"
    ]
    connection {
      host = "${aws_instance.maintenance-server.private_ip}"
      user = "ubuntu"
      port = "4422"
      private_key = "${file("~/.ssh/otava-key.pem")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
      bastion_user = "ec2-user"
      bastion_port = "4422"
    }
  }  
}

## Additional backups IAM Roles & policies

resource "aws_iam_role" "snapshot-role" {
  name = "FiareSnapshotRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
      "Name" = "FiareSnapshotRole",
      "Description" = "EC2 Role for snapshotting EC2 and RDS" 
  }
}

resource "aws_iam_instance_profile" "snapshot-profile" {
  name = "FiareSnapshotProfile"
  role = "${aws_iam_role.snapshot-role.name}"
}

resource "aws_iam_role_policy" "EC2-snapshot-policy" {
  name = "FiareEC2SnapshotPolicy"
  role = "${aws_iam_role.snapshot-role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["logs:*"],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": ["s3:*"],
            "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:ModifySnapshotAttribute",
        "ec2:ResetSnapshotAttribute"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "RDS-snapshot-policy" {
  name = "FiareRDSSnapshotPolicy"
  role = "${aws_iam_role.snapshot-role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["logs:*"],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": "rds:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:CreateDBClusterSnapshot",
        "rds:CreateDBSnapshot",
        "rds:ModifyDBClusterSnapshotAttribute",
        "rds:ResetDBClusterSnapshotAttribute",
        "rds:ModifyDBSnapshotAttribute",
        "rds:ResetDBSnapshotAttribute"        
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
}


##

## Import servers & related configuration

# resource "aws_instance" "import_az_a" {

#     ami = "ami-08d658f84a6d84a80"
#     instance_type = "c5.large"
#     #instance_type = "t2.micro"
#     monitoring = "true"
#     subnet_id = "${element(module.production_vpc.private_subnets, 0)}"
#      vpc_security_group_ids = [
#          "${module.production_sg.sg_allow_ssh_4422_bastion}",
#          "${module.production_sg.sg_allow_http}",
#          "${module.production_sg.sg_allow_https}",
#          "${module.production_sg.sg_allow_efs}"
#      ]
#     associate_public_ip_address = false
#     iam_instance_profile = "${aws_iam_instance_profile.ec2_assume_role.id}"
#     key_name = "otava-key"
#     tags {
#         Name = "Otava import server AZ a"
#         Billing = "Otava"
#     }
#     root_block_device {
#         volume_size = 20
#         delete_on_termination = true
#     }
#     user_data = <<EOF
# #!/bin/bash
# echo -e "\nPort 4422" >> /etc/ssh/sshd_config
# sudo service sshd restart
# sudo apt-get update -y
# sudo git clone https://github.com/aws/efs-utils
# cd efs-utils
# sudo apt-get -y install binutils
# sudo ./build-deb.sh
# sudo apt-get -y install ./build/amazon-efs-utils*deb
# cd ..
# sudo mkdir /data
# echo ${aws_efs_file_system.www-storage.dns_name}:/  /data   nfs nfsvers=4.1,_netdev,rw,noatime,nodiratime,hard,actimeo=120,timeo=600,retrans=2,noresvport,rsize=1048576,wsize=1048576,intr,nolock   0 0 >> /etc/fstab
# sudo mount -a
# EOF
# }


# resource "aws_instance" "import_az_c" {

#     ami = "ami-08d658f84a6d84a80"
#     instance_type = "c5.large"
#     monitoring = "true"
#     subnet_id = "${element(module.production_vpc.private_subnets, 2)}"
#      vpc_security_group_ids = [
#          "${module.production_sg.sg_allow_ssh_4422_bastion}",
#          "${module.production_sg.sg_allow_http}",
#          "${module.production_sg.sg_allow_https}",
#          "${module.production_sg.sg_allow_efs}"
#      ]
#     associate_public_ip_address = false
#     iam_instance_profile = "${aws_iam_instance_profile.ec2_assume_role.id}"
#     key_name = "otava-key"
#     tags {
#         Name = "Otava import server AZ c"
#         Billing = "Otava"
#     }

#     root_block_device {
#         volume_size = 20
#         delete_on_termination = false
#     }
#     user_data = <<EOF
# #!/bin/bash
# echo -e "\nPort 4422" >> /etc/ssh/sshd_config
# sudo service sshd restart
# sudo apt-get update -y
# sudo git clone https://github.com/aws/efs-utils
# cd efs-utils
# sudo apt-get -y install binutils
# sudo ./build-deb.sh
# sudo apt-get -y install ./build/amazon-efs-utils*deb
# sudo cd /
# sudo mkdir /data
# sudo echo ${aws_efs_file_system.www-storage.dns_name}:/  /data   nfs nfsvers=4.1,_netdev,rw,noatime,nodiratime,hard,actimeo=120,timeo=600,retrans=2,noresvport,rsize=1048576,wsize=1048576,intr,nolock 0 0 >> /etc/fstab
# sudo mount -a
# EOF
# }

# resource "aws_ebs_volume" "import_disk_a" {
#   availability_zone = "${element(module.production_vpc.azs, 0)}"
#   size = 300
#   type = "io1"
#   iops = "3000"
#   tags {
#     Name = "Import disk AZ A"
#     Billing = "Otava"
#   }
#   lifecycle {
#     prevent_destroy = false
#   }   
# }

# resource "aws_ebs_volume" "import_disk_c" {
#   availability_zone = "${element(module.production_vpc.azs, 2)}"
#   size = 600
#   type = "io1"
#   iops = "15000"
#   tags {
#     Name = "Import disk AZ C"
#     Billing = "Otava"
#   }
#   lifecycle {
#     prevent_destroy = false
#   }   
# }


# resource "aws_volume_attachment" "import_a" {
  
#   device_name  = "/dev/sdi"
#   volume_id    = "${aws_ebs_volume.import_disk_a.id}"
#   instance_id  = "${aws_instance.import_az_a.id}"
#   force_detach = true
#   #TODO - CHECK THIS - IS REBOOTING NEEDED? FOR SOME REASON ADDING SLEEP 10s, THIS WORKS
#   provisioner "file" {
#     source = "${var.infra_path}/bin/format-mount-ebs"
#     destination = "/tmp/format-mount-ebs"
#     connection {
#       host = "${aws_instance.import_az_a.private_ip}"
#       user = "ubuntu"
#       port = "4422"
#       private_key = "${file("~/.ssh/otava-key.pem")}"
#       bastion_host = "${aws_instance.bastion.public_ip}"
#       bastion_user = "ec2-user"
#       bastion_port = "4422"
#     }
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "bash /tmp/format-mount-ebs /dev/nvme1n1 /var/advantlabs",
#       "sudo chown 1000 /var/advantlabs"
#     ]
#     connection {
#       host = "${aws_instance.import_az_a.private_ip}"
#       user = "ubuntu"
#       port = "4422"
#       private_key = "${file("~/.ssh/otava-key.pem")}"
#       bastion_host = "${aws_instance.bastion.public_ip}"
#       bastion_user = "ec2-user"
#       bastion_port = "4422"
#     }
#   }  
# }

# resource "aws_volume_attachment" "import_c" {
  
#   device_name  = "/dev/sdi"
#   volume_id    = "${aws_ebs_volume.import_disk_c.id}"
#   instance_id  = "${aws_instance.import_az_c.id}"
#   force_detach = true
#   #TODO - CHECK THIS - IS REBOOTING NEEDED? FOR SOME REASON ADDING SLEEP 10s, THIS WORKS
#   provisioner "file" {
#     source = "${var.infra_path}/bin/format-mount-ebs"
#     destination = "/tmp/format-mount-ebs"
#     connection {
#       host = "${aws_instance.import_az_c.private_ip}"
#       user = "ubuntu"
#       port = "4422"
#       private_key = "${file("~/.ssh/otava-key.pem")}"
#       bastion_host = "${aws_instance.bastion.public_ip}"
#       bastion_user = "ec2-user"
#       bastion_port = "4422"
#     }
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "bash /tmp/format-mount-ebs /dev/xvdi /var/advantlabs",
#       "sudo chown 1000 /var/advantlabs"
#     ]
#     connection {
#       host = "${aws_instance.import_az_c.private_ip}"
#       user = "ubuntu"
#       port = "4422"
#       private_key = "${file("~/.ssh/otava-key.pem")}"
#       bastion_host = "${aws_instance.bastion.public_ip}"
#       bastion_user = "ec2-user"
#       bastion_port = "4422"
#     }
#   }  
# }