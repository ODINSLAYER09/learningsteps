resource "azurerm_container_registry" "acr" {
  name                = "evolutionacrj"
  location            = azurerm_resource_group.infra.location
  resource_group_name = azurerm_resource_group.infra.name
  sku                 = "Standard"
  admin_enabled       = false

  tags = var.tags
}
