resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "this" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Basic"
  admin_enabled       = false # CI/CD authenticates via OIDC + managed identity, not admin credentials
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-governance-analyzer-demo"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "this" {
  name                       = "cae-governance-analyzer-demo"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

# Container App Job instead of a long-running Container App: the governance
# analyzer is a batch CLI tool (run, produce a report, exit), not an HTTP
# service — a scheduled job is the correct Container Apps primitive for that.
resource "azurerm_container_app_job" "governance_check" {
  name                         = "job-governance-check"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  container_app_environment_id = azurerm_container_app_environment.this.id

  replica_timeout_in_seconds = 300
  replica_retry_limit        = 1

  identity {
    type = "SystemAssigned"
  }

  registry {
    server   = azurerm_container_registry.this.login_server
    identity = "System"
  }

  schedule_trigger_config {
    cron_expression          = var.job_cron_schedule
    parallelism              = 1
    replica_completion_count = 1
  }

  template {
    container {
      name   = "governance-analyzer"
      image  = "${azurerm_container_registry.this.login_server}/${var.container_image_name}:${var.container_image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}

resource "azurerm_role_assignment" "job_acr_pull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app_job.governance_check.identity[0].principal_id
}
