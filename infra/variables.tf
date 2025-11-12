variable "project_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "northeurope"
}

variable "db_password" {
  description = "Password for PostgreSQL admin user"
  type        = string
  sensitive   = true
}

variable "admin_ip" {
  description = "IP address allowed to access the database"
  type        = string
}

variable "admin_ip_single" {
  description = "Single Public IP address for PostgreSQL administrative access"
  type        = string
}