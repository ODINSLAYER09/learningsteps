terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-j"
    storage_account_name = "tfstateblobj"
    container_name       = "tfstate"
    key                  = "application/learningsteps/terraform.tfstate"
  }
}