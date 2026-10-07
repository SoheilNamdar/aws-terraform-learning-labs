# Lab 9 — Amazon S3
provider "aws" {
  region = var.aws_region

  access_key = "test"
  secret_key = "test"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "lab9" {
  bucket = "soheil-lab9-s3-advanced"
}

resource "aws_s3_bucket_versioning" "lab9" {
  bucket = aws_s3_bucket.lab9.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lab9" {
  bucket = aws_s3_bucket.lab9.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lab9" {
  bucket = aws_s3_bucket.lab9.id

  rule {
    id     = "archive-old-files"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}