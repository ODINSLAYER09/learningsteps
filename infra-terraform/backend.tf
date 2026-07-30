terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-j"
    storage_account_name = "tfstateblobj"
    container_name       = "tfstate"
    key                  = "application/learningsteps/terraform.tfstate"
    # Force Terraform to use Entra ID RBAC instead of requesting Storage Account Keys
    use_azuread_auth     = true
  }
}