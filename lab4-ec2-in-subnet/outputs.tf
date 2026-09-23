output "vpc_id" {
  description = "ID of the Lab 4 VPC."
  value       = aws_vpc.lab4.id
}

output "subnet_id" {
  description = "ID of the subnet containing the EC2 instance."
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.lab4.id
}

output "instance_private_ip" {
  description = "Private IP address assigned from the subnet."
  value       = aws_instance.lab4.private_ip
}

output "instance_public_ip" {
  description = "Public IP address assigned to the instance."
  value       = aws_instance.lab4.public_ip
}
