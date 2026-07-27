resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.infra.location
  resource_group_name = azurerm_resource_group.infra.name
  dns_prefix          = "${var.aks_cluster_name}-dns"

  default_node_pool {
    name            = "agentpool"
    node_count      = var.aks_node_count
    vm_size         = var.aks_node_vm_size
    vnet_subnet_id  = azurerm_subnet.aks.id
    max_pods        = var.aks_max_pods
    type            = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  tags = var.tags
}
