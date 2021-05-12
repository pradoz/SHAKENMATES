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

locals {
  vpc_id = "vpc-750cfb13"
}

# Route 53 records
resource "aws_route53_record" "gitlab" {
  zone_id = "Z0604056W5WW02JGQ0TK"
  name    = "gitlab.zprado.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.gitlab_instance.public_ip]
}

resource "aws_route53_record" "wiki" {
  zone_id = "Z0604056W5WW02JGQ0TK"
  name    = "wiki.zprado.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.wikijs_instance.public_ip]
}

resource "aws_route53_record" "rocket" {
  zone_id = "Z0604056W5WW02JGQ0TK"
  name    = "rpcket.zprado.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.rocketchat_instance.public_ip]
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

# WikiJS Instance
resource "aws_instance" "wikijs_instance" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t3.small"
  key_name = "horizons-ec2"

  user_data = file("install_wikijs.sh")
  security_groups = [aws_security_group.wikijs.name]

  tags = {
    Name = "WikiJS Instance"
  }
}

# RocketChat Instance
resource "aws_instance" "rocketchat_instance" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t3.small"
  key_name = "horizons-ec2"

  user_data = file("install_rocketchat.sh")
  security_groups = [aws_security_group.wikijs.name]

  tags = {
    Name = "RocketChat Instance"
  }
}

# WikiJS Security Group
resource "aws_security_group" "wikijs" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = local.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

