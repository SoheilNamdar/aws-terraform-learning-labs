variable "domain_name" {
  description = "Root domain managed in Route 53"
  type        = string
}

variable "app_subdomain" {
  description = "Application subdomain"
  type        = string
  default     = "app"
}