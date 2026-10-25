output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace Customer ID"
  value       = azurerm_log_analytics_workspace.law.workspace_id
}

output "azure_monitor_workspace_id" {
  description = "Resource ID of the Azure Monitor Workspace (Managed Prometheus)"
  value       = azurerm_monitor_workspace.amw.id
}

output "grafana_endpoint" {
  description = "URL endpoint for Azure Managed Grafana"
  value       = azurerm_dashboard_grafana.grafana.endpoint
}

output "action_group_id" {
  description = "Resource ID of the Critical On-Call Action Group"
  value       = azurerm_monitor_action_group.critical_oncall.id
}
