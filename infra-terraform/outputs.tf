output "resource_group_name" {
  description = "The name of the created resource group."
  value       = azurerm_resource_group.infra.name
}

output "vnet_id" {
  description = "The ID of the created virtual network."
  value       = azurerm_virtual_network.vnet.id
}

output "aks_subnet_id" {
  description = "The ID of the AKS subnet."
  value       = azurerm_subnet.aks.id
}

output "db_subnet_id" {
  description = "The ID of the database subnet."
  value       = azurerm_subnet.database.id
}

output "postgres_server_name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.postgres.name
}

output "postgres_server_fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_fqdn" {
  description = "The FQDN of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "key_vault_id" {
  description = "The ID of the created Key Vault."
  value       = azurerm_key_vault.kv.id
}

output "key_vault_uri" {
  description = "The URI of the created Key Vault."
  value       = azurerm_key_vault.kv.vault_uri
}

output "postgres_admin_secret_id" {
  description = "The Key Vault secret ID for the Postgres admin password."
  value       = azurerm_key_vault_secret.postgres_admin_password.id
}
