variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "system_node_count" {
  description = "Initial system node count"
  type        = number
  default     = 2
}

variable "system_node_min_count" {
  description = "Min system nodes"
  type        = number
  default     = 2
}

variable "system_node_max_count" {
  description = "Max system nodes"
  type        = number
  default     = 5
}

variable "system_node_size" {
  description = "System node VM size"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "user_node_min_count" {
  description = "Min user nodes"
  type        = number
  default     = 1
}

variable "user_node_max_count" {
  description = "Max user nodes"
  type        = number
  default     = 10
}

variable "user_node_size" {
  description = "User node VM size"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "subnet_id" {
  description = "Subnet ID for AKS"
  type        = string
}

variable "vnet_id" {
  description = "VNet ID"
  type        = string
}

variable "service_cidr" {
  description = "Kubernetes service CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "Kubernetes DNS service IP"
  type        = string
  default     = "10.0.0.10"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
}

variable "acr_id" {
  description = "ACR ID"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}