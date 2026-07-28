resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.infra.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres_vnet_link" {
  name                  = "postgres-vnet-link"
  resource_group_name   = azurerm_resource_group.infra.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = var.postgres_server_name
  resource_group_name = azurerm_resource_group.infra.name
  location            = azurerm_resource_group.infra.location
  version             = "15"

  administrator_login          = var.postgres_admin_username
  administrator_password       = var.postgres_admin_password
  storage_mb                  = var.postgres_storage_mb
  backup_retention_days       = var.postgres_backup_retention_days
  geo_redundant_backup_enabled = false
  delegated_subnet_id         = azurerm_subnet.database.id
  private_dns_zone_id         = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false

  sku_name = var.postgres_sku_name

  tags = var.tags

  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone
    ]
  }

  timeouts {
    create = "60m"
    delete = "60m"
  }
}
