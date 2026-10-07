terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    autoscaling = var.localstack_endpoint
    ec2         = var.localstack_endpoint
    elbv2       = var.localstack_endpoint
    sts         = var.localstack_endpoint
  }
}

resource "aws_vpc" "lab7" {
  cidr_block           = "10.7.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "lab7-vpc"
  }
}

resource "aws_internet_gateway" "lab7" {
  vpc_id = aws_vpc.lab7.id

  tags = {
    Name = "lab7-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = {
    a = {
      cidr = "10.7.1.0/24"
      az   = "${var.aws_region}a"
    }
    b = {
      cidr = "10.7.2.0/24"
      az   = "${var.aws_region}b"
    }
  }

  vpc_id                  = aws_vpc.lab7.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "lab7-public-${each.key}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab7.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab7.id
  }

  tags = {
    Name = "lab7-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "alb" {
  name        = "lab7-alb-sg"
  description = "Allow HTTP traffic to the application load balancer"
  vpc_id      = aws_vpc.lab7.id

  ingress {
    description = "HTTP from clients"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab7-alb-sg"
  }
}

resource "aws_security_group" "web" {
  name        = "lab7-web-sg"
  description = "Allow HTTP traffic from the application load balancer"
  vpc_id      = aws_vpc.lab7.id

  ingress {
    description     = "HTTP from the ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab7-web-sg"
  }
}

resource "aws_lb" "web" {
  name               = "lab7-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = values(aws_subnet.public)[*].id
}

resource "aws_lb_target_group" "web" {
  name     = "lab7-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.lab7.id

  health_check {
    enabled = true
    path    = "/"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "lab7-web-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(<<-EOT
    #!/bin/bash
    dnf install -y httpd
    echo "Hello from Lab 7: $(hostname)" > /var/www/html/index.html
    systemctl enable --now httpd
  EOT
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "lab7-web"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "lab7-web-asg"
  min_size            = var.asg_min_size
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  vpc_zone_identifier = values(aws_subnet.public)[*].id
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "lab7-web-asg-instance"
    propagate_at_launch = true
  }
}
