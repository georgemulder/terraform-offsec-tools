terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    godaddy = {
      source = "CruGlobal/godaddy"
    }
  }

  required_version = ">= 1.2.0"
}

provider "godaddy" {
  key    = "<key>"
  secret = "<secret>"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "hak5c2" {
  ami                    = "ami-01dd271720c1ba44f"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["<sg-hak5c2>", "<sg-ssh>"]
  subnet_id              = "subnet-<id>"
  key_name               = "hak5c2"
  user_data              = file("init.sh")
  iam_instance_profile   = "<iam_role_name>"
  tags = {
    Name     = "hak5c2"
    Servicio = "hak5c2"
  }
}

resource "godaddy_domain_record" "gd-domain" {
  domain = "example.com"
  record {
    name = "desiredsubdomain"
    type = "A"
    data = aws_instance.hak5c2.public_ip
    ttl = "600"
  }
}
output "instance_ip_1" {
  description = "The public ip for ssh access"
  value       = aws_instance.hak5c2.public_ip
}
