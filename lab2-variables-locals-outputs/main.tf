provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true

  endpoints {
    s3        = "http://s3.localhost.localstack.cloud:4566"
    s3control = "http://localhost.localstack.cloud:4566"
    sts       = "http://localhost:4566"
  }
}

locals {
  bucket_name = "${var.project_name}-bucket"
}

resource "aws_s3_bucket" "lab2" {
  bucket = local.bucket_name
}
