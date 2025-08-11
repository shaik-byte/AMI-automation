packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "source_ami" {
  type    = string
  default = "ami-0c94855ba95c71c99" # Amazon Linux 2 x86_64 (replace for your region if needed)
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ami_name" {
  type    = string
  default = "nginx-ami-{{timestamp}}"
}

source "amazon-ebs" "nginx" {
  region          = var.aws_region
  instance_type   = var.instance_type
  source_ami      = var.source_ami
  ssh_username    = "ec2-user"
  ami_name        = var.ami_name
  ami_description = "Nginx AMI built with Packer + Ansible"

  tags = {
    CreatedBy = "packer-ci"
    Purpose   = "nginx-base"
    Env       = "production"
  }
}

build {
  name    = "build-nginx-ami"
  sources = ["source.amazon-ebs.nginx"]

  provisioner "ansible" {
    playbook_file    = "ansible/install_nginx.yml"
    extra_arguments  = ["-vv"]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}
