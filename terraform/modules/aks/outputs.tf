output "cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_endpoint" {
  description = "AKS cluster Endpoint"
  value = azurerm_kubernetes_cluster.aks.kube_config.0.host
}

output "client_certificate" {
  description = "AKS Client Cert"
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "client_key" {
  description = "AKS Client Key"
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
}

output "cluster_ca_certificate" {
  description = "AKS Client CA Cert"
  value = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
}

output "kube_config" {
  description = "Kubernetes config"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "Kubelet identity object ID"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "principal_id" {
  description = "AKS system identity principal ID"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}