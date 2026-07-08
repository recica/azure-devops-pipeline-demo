output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "container_registry_login_server" {
  value = azurerm_container_registry.this.login_server
}

output "container_app_job_name" {
  value = azurerm_container_app_job.governance_check.name
}
