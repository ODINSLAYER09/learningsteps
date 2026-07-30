variable "resource_group_name" {
  description = "Name of the Azure resource group. Set this to the existing imported RG name."
  type        = string
  default     = "evolution-rg"
}

variable "subscription_id" {
  description = "Azure subscription ID to target for resource deployment."
  type        = string
}

variable "location" {
  description = "Azure location for the resource group and VNet."
  type        = string
}

variable "vnet_name" {
  description = "Name of the Azure virtual network."
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_name" {
  description = "Name of the subnet used by AKS."
  type        = string
  default     = "aks-subnet"
}

variable "aks_subnet_prefix" {
  description = "Address prefix for the AKS subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "db_subnet_name" {
  description = "Name of the subnet used by the database."
  type        = string
  default     = "db-subnet"
}

variable "db_subnet_prefix" {
  description = "Address prefix for the database subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "learningsteps-aks"
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS default node pool."
  type        = number
  default     = 2
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "aks_max_pods" {
  description = "Maximum pods per AKS node."
  type        = number
  default     = 30
}

variable "postgres_server_name" {
  description = "Name of the PostgreSQL Flexible Server."
  type        = string
  default     = "learningsteps-postgres"
}

variable "postgres_admin_username" {
  description = "Administrator username for PostgreSQL Flexible Server."
  type        = string
  default     = "pgadmin"
}

variable "postgres_admin_password" {
  description = "Administrator password for PostgreSQL Flexible Server."
  type        = string
  sensitive   = true
}

variable "postgres_storage_mb" {
  description = "Storage size for PostgreSQL Flexible Server in MB."
  type        = number
  default     = 32768
}

variable "postgres_backup_retention_days" {
  description = "Backup retention days for PostgreSQL Flexible Server."
  type        = number
  default     = 7
}

variable "postgres_sku_name" {
  description = "SKU name for PostgreSQL Flexible Server."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "key_vault_name" {
  description = "Name of the Key Vault to create."
  type        = string
  default     = "evolution-kv"
}

variable "key_vault_sku" {
  description = "SKU for the Key Vault."
  type        = string
  default     = "standard"
}

variable "tags" {
  description = "Tags to apply to Azure resources."
  type        = map(string)
  default = {
    environment = "dev"
    project     = "learningsteps"
  }
}
