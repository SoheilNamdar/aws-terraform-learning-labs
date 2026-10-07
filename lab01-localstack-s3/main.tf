terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region                  = "us-east-1"
  access_key              = "test"
  secret_key              = "test"
  s3_use_path_style     = true

  endpoints {
    s3 = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

# Next: add example resources like s3.tf and a docker-compose.yml to run LocalStack.