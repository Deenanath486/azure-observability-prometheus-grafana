variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "rg-observability-prod"
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "log_retention_days" {
  description = "Log Analytics retention in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Project     = "Observability-SRE"
    Owner       = "Deenanath Yadav"
  }
}
