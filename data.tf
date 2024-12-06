data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "state"
    values = ["available"]
  }
  
}

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        # values = ["amzn2-ami-hvm-2.0.????????.?-x86_64-gp2"]
        values = ["amzn2-ami-hvm-2.0.20230207.0-x86_64-gp2"]
    }
 
}

