# Lab 7 — Application Load Balancer and Auto Scaling Group

This lab creates a highly available web tier with an Application Load
Balancer (ALB) in front of an Auto Scaling Group (ASG). The infrastructure is
defined with Terraform and uses LocalStack for local AWS API emulation.

## Learning objectives

- Create public subnets in two Availability Zones
- Configure security groups for an ALB and web instances
- Create an HTTP target group and listener
- Define an EC2 launch template with user data
- Distribute ASG instances across multiple subnets
- Register the ASG with an ALB target group
- Inspect load-balancing and scaling resources with the AWS CLI

## Architecture

```text
Internet
   |
   v
Application Load Balancer
   |
   v
Target group
   |
   v
Auto Scaling Group
   |                 |
   v                 v
Public subnet A   Public subnet B
```

## Run the lab

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
aws --endpoint-url=http://localhost:4566 elbv2 describe-load-balancers
aws --endpoint-url=http://localhost:4566 elbv2 describe-target-groups
aws --endpoint-url=http://localhost:4566 autoscaling describe-auto-scaling-groups
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```

Terraform displays the emulated ALB DNS name after a successful apply:

```bash
terraform output alb_dns_name
```

## Clean up

```bash
terraform destroy
docker compose down
```

## Notes

The ELBv2 API used for the ALB requires LocalStack Base or a higher paid tier.
With LocalStack Community 4.14, Terraform validation and planning work, but
`terraform apply` returns a `501` license error when it reaches the load
balancer and target group. With a supported LocalStack license, the ALB DNS
name may still not route real HTTP traffic to emulated EC2 instances; use the
AWS CLI verification commands to inspect the resource relationships.
