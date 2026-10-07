output "vpc_id" {
  value = aws_vpc.main.id
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "application_url" {
  value = "https://${var.app_subdomain}.${var.domain_name}"
}

output "route53_zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}