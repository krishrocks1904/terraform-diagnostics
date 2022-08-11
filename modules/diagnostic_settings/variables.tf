variable "diagnostics_settings_name" {
    type = string
    description = "(optional) diagnostics setting name"
}

variable "resource_id" {
    type = string
    description = "(optional) resource id in which diagnotics to be enable"
}

variable "law_id" {
    type = string
    description = "(optional) log analytics where diagnotics will be log"
}

variable "logs" {
  
}

variable "metrics" {
  
}

variable "retention_days" {
  default = 30
}