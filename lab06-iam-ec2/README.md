# Lab 6 — IAM Role for EC2

This lab demonstrates how to create an IAM role with Terraform and attach it
to an EC2 instance through an instance profile. The infrastructure runs
locally with LocalStack.

## Learning objectives

By the end of this lab, I will be able to:

- Explain why an EC2 instance needs an IAM role
- Create an IAM trust policy for the EC2 service
- Create an IAM role with Terraform
- Create and attach an IAM policy to the role
- Create an IAM instance profile
- Attach the instance profile to an EC2 instance
- Inspect IAM and EC2 resources in LocalStack
- Destroy the resources safely with Terraform

## Planned architecture

```text
EC2 instance
    |
    v
IAM instance profile
    |
    v
IAM role
    |
    v
IAM policy
```

The role's trust policy allows the EC2 service to assume the role. The IAM
policy defines which AWS actions the instance is allowed to perform.

## Project structure

```text
lab06-iam-ec2/
├── docker-compose.yaml
├── README.md
├── main.tf          # Added during the lab
├── outputs.tf       # Added during the lab
└── variables.tf     # Added during the lab if needed
```

## Progress

- [x] Create the Lab 6 directory
- [x] Configure LocalStack with IAM, EC2, S3, and STS services
- [x] Create the initial README
- [ ] Configure the Terraform and AWS providers
- [ ] Create the networking resources required by EC2
- [x] Create the IAM trust policy
- [x] Create the IAM role
- [ ] Create the IAM role and permissions policy
- [ ] Create the IAM instance profile
- [ ] Create an EC2 instance that uses the instance profile
- [ ] Format and validate the Terraform configuration
- [ ] Plan and apply the infrastructure
- [ ] Verify the IAM and EC2 resources in LocalStack
- [ ] Destroy the infrastructure
- [ ] Document results and lessons learned

## Start LocalStack

From this directory, run:

```bash
docker compose up -d
docker compose ps
```

Check the LocalStack service health:

```bash
curl http://localhost:4566/_localstack/health
```

## Terraform workflow

The following commands will be used after the Terraform configuration has
been added:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

When the lab is complete, remove the Terraform-managed infrastructure and
stop LocalStack:

```bash
terraform destroy
docker compose down
```

## Verification commands

These commands will be used later to inspect the resources in LocalStack:

```bash
aws --endpoint-url=http://localhost:4566 iam list-roles
aws --endpoint-url=http://localhost:4566 iam list-instance-profiles
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```

## Notes and lessons learned

This section will be completed as the lab progresses.
