# AWS + Terraform Learning Labs

Hands-on AWS and Terraform learning repository using LocalStack for safe local cloud practice.

## Purpose

This repository documents my practical progression in Terraform and AWS infrastructure concepts.

The focus is on understanding each concept, implementing it manually, validating it, and documenting what I learned.

## Labs

### Lab 1 — LocalStack + Terraform + S3

Topics covered:

- Terraform AWS provider configuration
- LocalStack endpoints
- Mock AWS credentials
- Provider version constraints
- `.terraform.lock.hcl`
- Terraform state
- S3 bucket creation
- Implicit resource dependencies
- Validation workflow
- Independent verification with LocalStack

Folder:

`lab1-localstack-s3/`

---

### Lab 2 — Variables, Locals and Outputs

Topics covered:

- Terraform input variables
- Default variable values
- Locals
- Outputs
- Resource attributes
- S3 bucket naming from variables
- LocalStack S3 Control configuration
- `terraform fmt`
- `terraform validate`
- `terraform plan`
- `terraform apply`
- `terraform destroy`

Folder:

`lab2-variables-locals-outputs/`

## Workflow

Typical lab workflow:

```bash
docker compose up -d
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
terraform destroy
docker compose down
