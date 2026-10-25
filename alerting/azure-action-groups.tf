# Azure Monitor Action Groups for alerting
resource "azurerm_monitor_action_group" "critical_oncall" {
  name                = "ag-critical-oncall-sre"
  resource_group_name = var.resource_group_name
  short_name          = "crit-sre"

  email_receiver {
    name                    = "PrimarySRELead"
    email_address           = "deenanath.yadav@hotmail.com"
    use_common_alert_schema = true
  }

  webhook_receiver {
    name                    = "TeamsOpsBridge"
    service_uri             = "https://webhook.office.com/webhookb2/teams-bridge-alerts"
    use_common_alert_schema = true
  }

  tags = var.tags
}
