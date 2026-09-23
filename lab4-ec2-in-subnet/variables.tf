variable "aws_region" {
  description = "AWS region used by LocalStack."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the Lab 4 VPC."
  type        = string
  default     = "10.4.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.4.1.0/24"
}

variable "ami_id" {
  description = "AMI ID used by the LocalStack EC2 instance."
  type        = string
  default     = "ami-12345678"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "IPv4 CIDR allowed to reach port 22. Restrict this for real AWS."
  type        = string
  default     = "0.0.0.0/0"
}
