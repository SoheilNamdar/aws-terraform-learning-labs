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
  region                      = "us-east-1"
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

resource "aws_vpc" "lab5" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.lab5.id
  cidr_block = "10.0.1.0/24"
}

module "web_server" {
  source = "./modules/ec2-web"

  ami           = "ami-12345678"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
}
