terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

resource "aws_vpc" "lab4" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lab4-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab4.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "lab4-public-subnet"
  }
}

resource "aws_internet_gateway" "lab4" {
  vpc_id = aws_vpc.lab4.id

  tags = {
    Name = "lab4-internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab4.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab4.id
  }

  tags = {
    Name = "lab4-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "instance" {
  name        = "lab4-instance-sg"
  description = "Allow SSH access to the Lab 4 EC2 instance"
  vpc_id      = aws_vpc.lab4.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab4-instance-sg"
  }
}

resource "aws_instance" "lab4" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  associate_public_ip_address = true

  tags = {
    Name = "lab4-ec2"
  }
}
