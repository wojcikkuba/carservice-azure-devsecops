data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                = "${var.project_prefix}-kv-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [var.admin_ip]
  }
}

resource "azurerm_key_vault_access_policy" "terraform_user" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "Set",
    "List",
    "Delete"
  ]
}

resource "azurerm_key_vault_secret" "db_host" {
  name            = "DB-HOST"
  value           = azurerm_postgresql_flexible_server.db.fqdn
  key_vault_id    = azurerm_key_vault.kv.id
  content_type    = "Database Host"
  expiration_date = "2099-12-31T23:59:59Z"

  depends_on = [azurerm_key_vault_access_policy.terraform_user]
}

resource "azurerm_key_vault_secret" "db_user" {
  name            = "DB-USER"
  value           = "caradmin"
  key_vault_id    = azurerm_key_vault.kv.id
  content_type    = "Database User"
  expiration_date = "2099-12-31T23:59:59Z"

  depends_on = [azurerm_key_vault_access_policy.terraform_user]
}

resource "azurerm_key_vault_secret" "db_pass" {
  name            = "DB-PASS"
  value           = var.db_password
  key_vault_id    = azurerm_key_vault.kv.id
  content_type    = "Database Password"
  expiration_date = "2099-12-31T23:59:59Z"

  depends_on = [azurerm_key_vault_access_policy.terraform_user]
}

resource "azurerm_key_vault_secret" "db_name" {
  name            = "DB-NAME"
  value           = "cartracker"
  key_vault_id    = azurerm_key_vault.kv.id
  content_type    = "Database Name"
  expiration_date = "2099-12-31T23:59:59Z"

  depends_on = [azurerm_key_vault_access_policy.terraform_user]
}
