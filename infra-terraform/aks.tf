resource "azurerm_kubernetes_cluster" "aks" {
  name                              = var.aks_cluster_name
  location                          = azurerm_resource_group.infra.location
  resource_group_name               = azurerm_resource_group.infra.name
  dns_prefix                        = "${var.aks_cluster_name}-dns"
  role_based_access_control_enabled = true

  api_server_access_profile {
    authorized_ip_ranges = [
      "91.11.237.95/32" # Replace with your public IP, office IP, or NAT gateway CIDR
    ]
  }

  default_node_pool {
    name           = "agentpool"
    node_count     = var.aks_node_count
    vm_size        = var.aks_node_vm_size
    vnet_subnet_id = azurerm_subnet.aks.id
    max_pods       = var.aks_max_pods
    type           = "VirtualMachineScaleSets"
  }



  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
    service_cidr      = "172.16.0.0/16"
    dns_service_ip    = "172.16.0.10"
  }

  tags = var.tags
}

# Terraform equivalent of: az aks update --attach-acr
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.aks.id
  skip_service_principal_aad_check = true # avoids AAD replication race
}