terraform {
  backend "azurerm" {
    # These values will be provided via backend-config during init
    # terraform init -backend-config="storage_account_name=..."
  }
}