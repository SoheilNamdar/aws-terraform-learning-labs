terraform {
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
  }
}

resource "aws_vpc" "lab8" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lab8-vpc"
  }
}

resource "aws_subnet" "private_db_a" {
  vpc_id            = aws_vpc.lab8.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "lab8-private-db-a"
  }
}

resource "aws_subnet" "private_db_b" {
  vpc_id            = aws_vpc.lab8.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "eu-west-3b"

  tags = {
    Name = "lab8-private-db-b"
  }
}

resource "aws_security_group" "app_sg" {
  name   = "lab8-app-sg"
  vpc_id = aws_vpc.lab8.id

  tags = {
    Name = "lab8-app-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "lab8-rds-sg"
  vpc_id = aws_vpc.lab8.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  tags = {
    Name = "lab8-rds-sg"
  }
}

resource "aws_db_subnet_group" "db_subnets" {
  name = "lab8-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_db_a.id,
    aws_subnet.private_db_b.id
  ]

  tags = {
    Name = "lab8-db-subnet-group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "lab8-mysql"
  engine                 = "mysql"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  username               = var.db_username
  password               = "ChangeMe123!"
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}

