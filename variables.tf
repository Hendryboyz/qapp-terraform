variable "app_name" {
  type    = string
  default = "qapp"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "resource_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "subnets" {
  type    = set(string)
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

variable "hostname" {
  type = string
}

variable "is_postgres_enabled" {
  type    = bool
  default = false
}

variable "postgres_snapshot_id" {
  type        = string
  description = "allow to recreate the PostgreSQL with the same data from recycled DB"
  default     = null
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "is_ses_enabled" {
  type    = bool
  default = false
}

variable "ses_from_subdomain" {
  type    = string
  default = "support"
}
