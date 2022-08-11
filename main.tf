terraform {
  required_providers {
    azurerm = {
      version = "~> 2.88.1"
      source = "hashicorp/azurerm"
    }
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
  }

backend "azurerm" {
}
}

provider "azurerm" {
  # whilst the `xversion` attribute is optional, we recommend pinning to a given version of the Provider
   features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
   
}

resource "azurecaf_name" "rg_example" {
  name          = "demogroup"
  resource_type = "azurerm_resource_group"
  prefixes      = ["dev"]
  clean_input   = true
}

resource "azurerm_resource_group" "resource_group" {
  name     = azurecaf_name.rg_example.result
  location = "uksouth"
  tags     = merge(var.default_tags, tomap({ "type" = "resource" }))
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}


resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-dev-blog-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                        = "kv-dev-blog-021"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

module "diagnostic_settings" {
  source = "./modules/diagnostic_settings"
  diagnostics_settings_name   = "ds-log-analytics"
  resource_id                 = azurerm_key_vault.example.id
  law_id                     = azurerm_log_analytics_workspace.example.id
  logs                       = [
                                  "AuditEvent"
                               ]
  metrics                    = [
                                 "AllMetrics"
                               ]
  retention_days             = var.retention_days
}


