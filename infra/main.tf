terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "d0bc3bc6-365d-4cdf-8af4-967272fdf752"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_app_service_plan" "plan" {
  name                = "${var.project_prefix}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }

}

resource "azurerm_app_service" "app" {
  name                = "${var.project_prefix}-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
  client_cert_enabled = true

  site_config {
    health_check_path = "/health"
    linux_fx_version = "DOCKER|wojcikkuba/carservice-frontend:latest"
    always_on        = true
    ftps_state = "Disabled"
    http2_enabled = true
  }

  auth_settings {
    enabled = true
  }

  logs {
    detailed_error_messages_enabled = true
    failed_request_tracing_enabled = true
    http_logs {
      file_system {
        retention_in_days = 4
        retention_in_mb = 25
      }
    }
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "80"
  }

  https_only = true
}