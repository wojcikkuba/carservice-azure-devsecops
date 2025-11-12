resource "azurerm_postgresql_flexible_server" "db" {
  name                          = "${var.project_prefix}-db"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "13"
  administrator_login           = "caradmin"
  administrator_password        = var.db_password
  sku_name                      = "B_Standard_B1ms"
  storage_mb                    = 32768
  backup_retention_days         = 7
  auto_grow_enabled             = true
  public_network_access_enabled = true

  lifecycle {
    ignore_changes = [
      zone,
      high_availability
    ]
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Zezwolenie na wszystkie polaczenia
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_my_ip" {
  name             = "AllowMyAdminIP"
  server_id        = azurerm_postgresql_flexible_server.db.id
  #start_ip_address = "0.0.0.0"
  #end_ip_address   = "255.255.255.255"
  start_ip_address = "83.6.89.114"
  end_ip_address = "83.6.89.114"
}

resource "azurerm_postgresql_flexible_server_database" "car_db" {
  name      = "cartracker"
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "C"
  charset   = "UTF8"
}
