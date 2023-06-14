terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "redirector-1" {
  ami                    = "ami-01dd271720c1ba44f"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-<ID>"]
  subnet_id              = "subnet-<ID>"
  key_name               = "Redirector"
  user_data              = file("init.sh")
  tags = {
    Name = "redirector"
  }
}
resource "aws_instance" "redirector-2" {
  ami                    = "ami-01dd271720c1ba44f"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-<ID>"]
  subnet_id              = "subnet-<ID>"
  key_name               = "Redirector"
  user_data              = file("init.sh")
  tags = {
    Name = "redirector"
  }
}
output "instance_ip_1" {
  description = "The public ip for ssh access"
  value       = aws_instance.redirector-1.public_ip
}
output "instance_ip_2" {
  description = "The public ip for ssh access"
  value       = aws_instance.redirector-2.public_ip
}
