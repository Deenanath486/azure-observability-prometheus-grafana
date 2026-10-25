terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# 2. Centralized Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-observability-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = var.tags
}

# 3. Azure Monitor Workspace (Azure Managed Prometheus)
resource "azurerm_monitor_workspace" "amw" {
  name                = "amw-prometheus-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = var.tags
}

# 4. Azure Managed Grafana
resource "azurerm_dashboard_grafana" "grafana" {
  name                              = "grafana-enterprise-${var.environment}"
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = azurerm_resource_group.rg.location
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = true
  sku                               = "Standard"

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.amw.id
  }

  tags = var.tags
}

# 5. Role Assignment: Grant Grafana System Identity "Monitoring Reader" to read Azure Monitor metrics
data "azurerm_subscription" "primary" {}

resource "azurerm_role_assignment" "grafana_monitoring_reader" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_dashboard_grafana.grafana.identity[0].principal_id
}

# 6. Action Groups for Alert Routing
resource "azurerm_monitor_action_group" "critical_oncall" {
  name                = "ag-critical-oncall-sre"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "crit-sre"

  email_receiver {
    name                    = "PrimarySRELead"
    email_address           = "deenanath.yadav@hotmail.com"
    use_common_alert_schema = true
  }

  tags = var.tags
}
