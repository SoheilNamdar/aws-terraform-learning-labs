resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lab10-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab10-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab10-public-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "lab10-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "lab10-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = false

  tags = {
    Name = "lab10-private-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = false

  tags = {
    Name = "lab10-private-b"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "lab10-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "lab10-nat"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "lab10-private-rt"
  }
}

resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "alb" {
  name        = "lab10-alb-sg"
  description = "Allow web traffic to the ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "lab10-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_out" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "ec2" {
  name        = "lab10-ec2-sg"
  description = "Allow application traffic only from the ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "lab10-ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_http_from_alb" {
  security_group_id            = aws_security_group.ec2.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ec2_out" {
  security_group_id = aws_security_group.ec2.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_lb" "app" {
  name               = "lab10-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name = "lab10-alb"
  }
}

resource "aws_lb_target_group" "app" {
  name     = "lab10-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "lab10-target-group"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = aws_acm_certificate_validation.app.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "lab10-app-"
  image_id      = "image_id = data.aws_ami.amazon_linux.id"
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "<h1>Lab 10 - Route 53 + ALB</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "lab10-app"
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name = "lab10-asg"

  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  target_group_arns = [
    aws_lb_target_group.app.arn
  ]

  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}

resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name = "lab10-zone"
  }
}

resource "aws_acm_certificate" "app" {
  domain_name       = "${var.app_subdomain}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "app" {
  certificate_arn = aws_acm_certificate.app.arn

  validation_record_fqdns = [
    for record in aws_route53_record.acm_validation :
    record.fqdn
  ]
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "${var.app_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}