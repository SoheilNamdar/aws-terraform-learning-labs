

output "bucket_arn" {
  description = "ARN of the S3 bucket created in LocalStack."
  value       = aws_s3_bucket.lab2.arn
}