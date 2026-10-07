# Lab 4: Put an EC2 Instance in a Subnet

This lab uses Terraform and LocalStack to create an EC2 instance inside a
public subnet. It runs locally and does not create resources in a real AWS
account.

## What this project creates

- One VPC (`10.4.0.0/16`)
- One public subnet (`10.4.1.0/24`)
- An internet gateway and public route table
- A security group allowing SSH
- One `t3.micro` EC2 instance in the public subnet

The important connection is in `main.tf`:

```hcl
resource "aws_instance" "lab4" {
  subnet_id = aws_subnet.public.id
  # ...
}
```

This reference places the instance in the subnet and also tells Terraform to
create the subnet before the instance.

## Prerequisites

- Docker with Docker Compose
- Terraform 1.5 or newer
- AWS CLI (optional)

## Run the lab

```bash
docker compose up -d
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Enter `yes` when prompted. Then inspect the resource IDs and IP addresses:

```bash
terraform output
```

You can also inspect the local EC2 instance with the AWS CLI:

```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
  --region us-east-1
```

## Clean up

```bash
terraform destroy
docker compose down
```

The default AMI is a test ID suitable for LocalStack. Before adapting this lab
to real AWS, choose a valid AMI for the target region and restrict `ssh_cidr`
to your own IP address.
