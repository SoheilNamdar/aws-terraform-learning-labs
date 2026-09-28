# Lab 5 — Terraform Modules

This lab demonstrates how to extract reusable infrastructure into a local
Terraform module. It creates a VPC and subnet in the root module, then passes
the subnet ID to an `ec2-web` module that creates an EC2 instance.

## Concepts covered

- Local Terraform modules
- Module input variables
- Module outputs
- Passing resource attributes into modules
- LocalStack provider endpoints

## Run the lab

```bash
docker compose up -d
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```

When finished:

```bash
terraform destroy
docker compose down
```
