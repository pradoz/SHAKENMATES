terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.38.0"
    }
  }
}

provider "aws" {
  # Configuration options
  # profile=default
  region = "us-west-1"
}

# Setup hosted zone for gitlab
# resource "aws_route53_zone" "gitlab_zone" {
#   name = "gitlab.zprado.com"
# 
#   tags = {
#     Environment = "prod"
#   }
# }

resource "aws_route53_record" "www" {
  zone_id = "Z0604056W5WW02JGQ0TK"
  name    = "gitlab.zprado.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.gitlab_instance.public_ip]
}

data "aws_ami" "ubuntu_ami" {
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

# Self-hosted GitLab instance
resource "aws_instance" "gitlab_instance" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t3.medium"
  key_name = "horizons-ec2"

  tags = {
    Name = "Gitlab Instance"
  }
}

# WikiJS instance
resource "aws_instance" "wikijs_instance" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t3.small"
  key_name = "horizons-ec2"

  user_data = file("install_docker.sh")

  tags = {
    Name = "WikiJS Instance"
  }
}

