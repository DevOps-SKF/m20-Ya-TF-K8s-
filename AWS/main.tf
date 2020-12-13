terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.21.0"
    }
  }
  backend "s3" {
    bucket = "bcommon"
    key    = "tf/m20-aws-k8s.tfstate"
    # export AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
  }
}  

provider "aws" {
  # Configuration options
  region = "eu-central-1"
}

resource "aws_vpc" "SKF" {
  cidr_block       = "172.19.0.0/22"
  instance_tenancy = "default"

  tags = {
    Name = "SKF"
  }
}

resource "aws_subnet" "k8s" {
  vpc_id     = aws_vpc.SKF.id
  cidr_block = "172.19.0.0/24"

  tags = {
    Name = "SKF_k8s"
    purpose     = "k8s" 
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "vmMaster" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" # t2.medium
  # t2.micro spot $0.004

  subnet_id = aws_subnet.k8s.id

  root_block_device = [
    {
      volume_type = "hdd" # gp2 (SSD);  (Magnetic)
      volume_size = 10
    },
  ]

  tags = {
    Name = "Master"
  }
}

