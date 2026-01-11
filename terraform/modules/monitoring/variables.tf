variable "environment" {
  description = "Environment name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "aks_cluster_id" {
  description = "AKS cluster ID"
  type        = string
}

variable "admin_email" {
  description = "Admin email for alerts"
  type        = string
  default     = "admin@example.com"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}