output "frontend_fqdn" {
  value = azurerm_container_app.frontend_app.ingress
}
