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

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "pe_subnet" {
  name                 = "pe-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app_subnet" {
  name = "app-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [ "10.0.2.0/24" ]
  delegation {
    name = "default"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# checkov:skip=CKV_AZURE_71: Tożsamość zarządzana nie jest wymagana dla aplikacji frontendowej.
# checkov:skip=CKV_AZURE_88: Aplikacja kontenerowa jest bezstanowa.
# checkov:skip=CKV_AZURE_16: Rejestracja w Azure AD jest celowo wyłączona.
# checkov:skip=CKV_AZURE_13: Uwierzytelnianie App Service (Easy Auth) jest celowo wyłączone.
# checkov:skip=CKV_AZURE_17: Publiczna aplikacja webowa - nie wymuszamy certyfikatu klienta
resource "azurerm_app_service" "app" {
  name                = "${var.project_prefix}-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
  https_only          = true
  client_cert_enabled = false

  site_config {
    health_check_path = "/health"
    linux_fx_version  = "DOCKER|wojcikkuba/carservice-frontend:latest"
    always_on         = true
    ftps_state        = "Disabled"
    http2_enabled     = true
  }

  auth_settings {
    enabled = false
  }

  logs {
    detailed_error_messages_enabled = true
    failed_request_tracing_enabled  = true
    http_logs {
      file_system {
        retention_in_days = 4
        retention_in_mb   = 25
      }
    }
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "80"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name = "${var.project_prefix}-nsg"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "pe_nsg_association" {
  subnet_id                 = azurerm_subnet.pe_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "app_nsg_association" {
  subnet_id                 = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}