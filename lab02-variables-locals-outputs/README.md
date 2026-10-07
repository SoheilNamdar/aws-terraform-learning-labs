# Lab 2: Terraform with LocalStack S3

This lab uses Terraform to create an Amazon S3 bucket in LocalStack. LocalStack
provides a local AWS-compatible environment, so the lab does not create resources
in a real AWS account or incur AWS charges.

## What this project creates

- A LocalStack container with the S3, S3 Control, and STS services enabled
- An S3 bucket named `<project_name>-bucket`
- A Terraform output containing the bucket ARN

The default project name is `soheil-lab`, so the default bucket name is
`soheil-lab-bucket`.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Terraform](https://developer.hashicorp.com/terraform/install)
- AWS CLI (optional, for inspecting the local bucket)

## Run the lab

From the `lab2` directory, start LocalStack:

```bash
docker compose up -d
```

Initialize and verify the Terraform configuration:

```bash
terraform init
terraform fmt -check
terraform validate
```

Review and apply the changes:

```bash
terraform plan
terraform apply
```

Enter `yes` when Terraform asks for confirmation. After the apply completes,
display the bucket ARN with:

```bash
terraform output bucket_arn
```

If the AWS CLI is installed, list the buckets in LocalStack with:

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

## Customize the bucket name

Pass a different project name on the command line:

```bash
terraform apply -var="project_name=my-project"
```

This example creates a bucket named `my-project-bucket`.

## Clean up

Destroy the Terraform-managed resources, then stop LocalStack:

```bash
terraform destroy
docker compose down
```

To also remove the LocalStack Docker volume, run:

```bash
docker compose down -v
```

## Repository notes

The `.gitignore` excludes generated Terraform directories, state files, variable
files that may contain secrets, and saved plan files. The provider lock file
`.terraform.lock.hcl` should be committed so provider versions remain consistent.

The credentials in `main.tf` are test values used only by LocalStack. Do not use
real AWS credentials in this project or commit secrets to the repository.
