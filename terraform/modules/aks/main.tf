# Datasource to get latest Azure AKS latest version
data "azurerm_kubernetes_service_versions" "current" {
  location        = var.location
  include_preview = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = var.system_node_size
    vnet_subnet_id      = var.subnet_id
    enable_auto_scaling = true
    min_count           = var.system_node_min_count
    max_count           = var.system_node_max_count
    os_disk_size_gb     = 100
    
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }
    
    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    load_balancer_sku  = "standard"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  auto_scaler_profile {
    balance_similar_node_groups = true
    max_graceful_termination_sec = 600
  }

  tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.user_node_size
  vnet_subnet_id        = var.subnet_id
  
  enable_auto_scaling = true
  min_count           = var.user_node_min_count
  max_count           = var.user_node_max_count
  os_disk_size_gb     = 128
  
  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "workload"      = "application"
  }
  
  upgrade_settings {
    max_surge = "33%"
  }
  
  tags = var.tags
}

resource "azurerm_role_assignment" "aks_network" {
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_acr" {
  for_each = var.acr_id != "" ? { this = var.acr_id } : {}
  scope                = each.value
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}