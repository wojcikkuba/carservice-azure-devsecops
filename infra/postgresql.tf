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
  geo_redundant_backup_enabled  = true

  lifecycle {
    ignore_changes = [
      zone,
      high_availability
    ]
  }
}

resource "azurerm_private_endpoint" "db_pe" {
  name                = "${azurerm_postgresql_flexible_server.db.name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_service_connection {
    name                           = "db-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_postgresql_flexible_server.db.id
    subresource_names              = ["postgresqlServer"]
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [ azurerm_private_dns_zone.db_dns.id ]
  }
}

resource "azurerm_private_dns_zone" "db_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "db_dns_link" {
  name                  = "db-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.db_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_a_record" "db_a_record" {
  name                = azurerm_postgresql_flexible_server.db.name
  zone_name           = azurerm_private_dns_zone.db_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.db_pe.private_service_connection[0].private_ip_address]
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_my_ip" {
  name             = "AllowMyAdminIP"
  server_id        = azurerm_postgresql_flexible_server.db.id
  start_ip_address = var.admin_ip_single
  end_ip_address = var.admin_ip_single
}

resource "azurerm_postgresql_flexible_server_database" "car_db" {
  name      = "cartracker"
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "C"
  charset   = "UTF8"
}