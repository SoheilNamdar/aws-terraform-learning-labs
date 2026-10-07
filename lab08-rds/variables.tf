variable "aws_region" {
  default = "eu-west-3"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  default = 20
}

variable "db_username" {
  default = "admin"
}