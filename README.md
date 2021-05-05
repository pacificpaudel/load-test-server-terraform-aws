# load-test-server-terraform-aws

The main motives behind this terraform build is to build a test server to load test websites

For this build i am assuming Jmeter as test tool but it can be anything depending on your need. 

Just that it sets up the environment for starting Cli based test i.e actual test


## This infra Build the follow features



| VPC | Subnet | Instances | EBS | Internet Gateway | Route Tables | Security Group |
| :-- | :----: | --------: | :-- | :--------------: | -----------: |  ------------: |
|  1  |   1    |    1      |  1  |        1         |       1      |        1       |