variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}


variable "schema_registry_id" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "schema_registry_rest_endpoint" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "schema_registry_api_key" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "schema_registry_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}