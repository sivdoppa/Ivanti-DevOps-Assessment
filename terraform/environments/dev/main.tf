terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

locals {
  environment = "dev"
  location    = "eastus"
  common_tags = {
    Environment = "dev"
    Project     = "DevOps-Assessment"
    ManagedBy   = "Terraform"
    Owner       = "DevOps-Team"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-aks-${local.environment}"
  location = local.location
  tags     = local.common_tags
}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Networking Module
module "networking" {
  source = "../../modules/networking"
  
  environment         = local.environment
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  vnet_address_space  = ["10.1.0.0/16"]
  aks_subnet_prefix   = "10.1.0.0/20"
  
  tags = local.common_tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-aks-${local.environment}-${random_string.suffix.result}"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = local.common_tags
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "acr${local.environment}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  sku                 = "Standard"
  admin_enabled       = false  # Use Managed Identity instead
  
  tags = local.common_tags
}

# AKS Cluster Module
module "aks" {
  source = "../../modules/aks"
  
  cluster_name               = "aks-${local.environment}"
  location                   = local.location
  resource_group_name        = azurerm_resource_group.main.name
  dns_prefix                 = "aks-${local.environment}"
  environment                = local.environment
  
  # System node pool
  system_node_count      = 2
  system_node_min_count  = 2
  system_node_max_count  = 3
  system_node_size       = "Standard_D2s_v3"
  
  # User node pool
  user_node_min_count = 1
  user_node_max_count = 5
  user_node_size      = "Standard_D2s_v3"
  
  # Networking
  subnet_id       = module.networking.aks_subnet_id
  vnet_id         = module.networking.vnet_id
  service_cidr    = "10.0.0.0/16"
  dns_service_ip  = "10.0.0.10"
  
  # Monitoring
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  
  # ACR integration (Managed Identity - no passwords!)
  acr_id = azurerm_container_registry.main.id
  
  tags = local.common_tags
}

# Key Vault for secrets
resource "azurerm_key_vault" "main" {
  name                       = "kv-${local.environment}-${random_string.suffix.result}"
  location                   = local.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  
  tags = local.common_tags
}

data "azurerm_client_config" "current" {}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"
  
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  aks_cluster_id      = module.aks.cluster_id
  admin_email         = var.admin_email
  
  tags = local.common_tags
}