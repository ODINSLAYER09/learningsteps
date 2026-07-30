resource "azurerm_container_registry" "acr" {
  name                = "evolutionacrj"
  location            = azurerm_resource_group.infra.location
  resource_group_name = azurerm_resource_group.infra.name
  sku                 = "Standard"
  admin_enabled       = false

  tags = var.tags
}
# Grant AKS kubelet identity the AcrPull role on the registry so nodes can pull images
resource "azurerm_role_assignment" "acr_pull_for_aks" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_container_registry.acr,
  ]
}
