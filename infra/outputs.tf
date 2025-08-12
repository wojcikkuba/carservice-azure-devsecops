output "app_service_url" {
  value = "https://${azurerm_app_service.app.default_site_hostname}"
}

output "backend_app_service_url" {
  value = "https://${azurerm_app_service.backend_app.default_site_hostname}"
}

output "database_fqdn" {
  value = azurerm_postgresql_flexible_server.db.fqdn
}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}
