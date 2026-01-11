variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.3"
}

variable "admin_email" {
  description = "Admin email for alerts"
  type        = string
  default     = "admin@example.com"
}