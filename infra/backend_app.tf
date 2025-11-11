resource "azurerm_app_service" "backend_app" {
  name                = "${var.project_prefix}-backend-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
  https_only          = true
  client_cert_enabled = false
  
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

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_identity.id]
  }

  site_config {
    linux_fx_version = "DOCKER|wojcikkuba/carservice-backend:latest"
    always_on        = true
    ftps_state = "Disabled"
    http2_enabled = true
  }

  app_settings = {
    WEBSITES_PORT = "3000"
    DB_HOST       = azurerm_postgresql_flexible_server.db.fqdn
    DB_USER       = "caradmin"
    DB_PASS       = var.db_password
    DB_NAME       = "cartracker"
    NODE_ENV      = "production"
  }

  depends_on = [
    azurerm_key_vault_access_policy.backend_app
  ]
}

resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "${var.project_prefix}-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_key_vault_access_policy" "backend_app" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.app_identity.principal_id

  secret_permissions = ["Get", "List"]
}
