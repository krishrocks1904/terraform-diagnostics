data "azurerm_monitor_diagnostic_categories" "this" {
  resource_id = var.resource_id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = var.diagnostics_settings_name
  target_resource_id         = var.resource_id
  log_analytics_workspace_id = var.law_id
  
  dynamic "log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.this.logs)

    content {
      category = log.value
      enabled  = contains(var.logs,log.value) 

      retention_policy {
          enabled = contains(var.logs,log.value)
          days    = contains(var.logs,log.value) == true ? var.retention_days :0
      }
    }
  }


  dynamic "metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.this.metrics)

    content {
      category = metric.value
      enabled  = contains(var.metrics,metric.value) 

      retention_policy {
        enabled = contains(var.metrics,metric.value)
        days    = contains(var.metrics,metric.value) == true ? var.retention_days :0
      }
    }
  }

  lifecycle {
    ignore_changes = [ metric ]
  }
}