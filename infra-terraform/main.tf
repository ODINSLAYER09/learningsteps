resource "azurerm_resource_group" "infra" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.infra.location
  resource_group_name = azurerm_resource_group.infra.name
  address_space       = var.address_space

  tags = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  resource_group_name  = azurerm_resource_group.infra.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.aks_subnet_prefix]

  delegation {
    name = "aks-delegation"

    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
    }
  }
}

resource "azurerm_subnet" "database" {
  name                 = var.db_subnet_name
  resource_group_name  = azurerm_resource_group.infra.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.db_subnet_prefix]
}
