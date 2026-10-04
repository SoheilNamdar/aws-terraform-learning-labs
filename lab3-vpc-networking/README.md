# Lab 3 — VPC Networking

This lab builds a basic AWS network with Terraform and LocalStack. It creates
a VPC with public and private subnets, separate route tables, an internet
gateway, and a NAT gateway.

## Concepts covered

- VPC CIDR blocks
- Public and private subnets
- Internet gateways
- Elastic IP addresses
- NAT gateways
- Public and private route tables
- Route table associations
- Explicit Terraform dependencies

## Architecture

```text
VPC: 10.0.0.0/16
|
|-- Public subnet: 10.0.1.0/24
|   |-- Internet gateway
|   |-- Public route: 0.0.0.0/0 -> Internet gateway
|   `-- NAT gateway with an Elastic IP
|
`-- Private subnet: 10.0.2.0/24
    `-- Private route: 0.0.0.0/0 -> NAT gateway
```

## Files

- `main.tf` — provider, VPC, subnet, gateway, and routing resources
- `docker-compose.yaml` — LocalStack service configuration
- `.terraform.lock.hcl` — locked Terraform provider versions

Terraform state files are local runtime data and are excluded from Git.

## Run the lab

Start LocalStack:

```bash
docker compose up -d
docker compose ps
```

Initialize and check the Terraform configuration:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Create the infrastructure:

```bash
terraform apply
```

## Verify the resources

```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs
aws --endpoint-url=http://localhost:4566 ec2 describe-subnets
aws --endpoint-url=http://localhost:4566 ec2 describe-internet-gateways
aws --endpoint-url=http://localhost:4566 ec2 describe-nat-gateways
aws --endpoint-url=http://localhost:4566 ec2 describe-route-tables
```

## Clean up

Remove the Terraform-managed infrastructure before stopping LocalStack:

```bash
terraform destroy
docker compose down
```
