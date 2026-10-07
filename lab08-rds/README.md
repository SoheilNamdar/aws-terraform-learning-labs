# Lab 8 — RDS MySQL Database

This lab demonstrates how to provision a private MySQL database with Amazon
RDS and Terraform. The database is placed in two private subnets and accepts
MySQL traffic only from resources associated with the application security
group.

## Learning objectives

- Create private database subnets in multiple Availability Zones
- Create an RDS DB subnet group
- Control database access with security-group references
- Configure an RDS MySQL instance with Terraform variables
- Keep the database inaccessible from the public internet
- Expose the database endpoint as a Terraform output

## Architecture

```text
VPC: 10.0.0.0/16
|
|-- Application security group
|          |
|          | MySQL TCP/3306
|          v
|-- RDS security group
|          |
|          v
`-- DB subnet group
    |-- Private DB subnet A: 10.0.10.0/24 (eu-west-3a)
    `-- Private DB subnet B: 10.0.20.0/24 (eu-west-3b)
             |
             v
        MySQL RDS instance
```

## Resources

The Terraform configuration creates:

- One VPC with DNS support and DNS hostnames enabled
- Two private subnets in separate Availability Zones
- An application security group
- An RDS security group that permits MySQL traffic from the application group
- One RDS DB subnet group
- One private MySQL RDS instance

## Input variables

| Variable | Default | Description |
| --- | --- | --- |
| `aws_region` | `eu-west-3` | AWS region used by the provider |
| `db_instance_class` | `db.t3.micro` | RDS instance class |
| `db_allocated_storage` | `20` | Database storage in GiB |
| `db_username` | `admin` | Database administrator username |

## Output

After a successful apply, Terraform exposes the database endpoint:

```bash
terraform output rds_endpoint
```

## Run the lab

From this directory:

```bash
docker compose up -d
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

## Verify resources

```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs
aws --endpoint-url=http://localhost:4566 ec2 describe-subnets
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups
aws --endpoint-url=http://localhost:4566 rds describe-db-subnet-groups
aws --endpoint-url=http://localhost:4566 rds describe-db-instances
```

## Clean up

```bash
terraform destroy
docker compose down
```

## LocalStack note

RDS emulation is not available in every LocalStack edition. The current
provider configuration redirects EC2 requests to LocalStack, but RDS must also
be enabled in `docker-compose.yaml` and configured as a provider endpoint
before this lab can be applied entirely against LocalStack. Do not run
`terraform apply` with real AWS credentials unless you intend to create a
billable RDS instance.
