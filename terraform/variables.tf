variable "resource_group_name" {
  description = "Name of the resource group that holds all resources for this demo."
  type        = string
  default     = "rg-governance-analyzer-demo"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "switzerlandnorth"
}

variable "container_registry_name" {
  description = "Globally unique name for the Azure Container Registry (alphanumeric only)."
  type        = string
  default     = "acrgovernanceanalyzer"
}

variable "container_image_name" {
  description = "Repository name for the governance analyzer image inside the registry."
  type        = string
  default     = "governance-analyzer"
}

variable "container_image_tag" {
  description = "Tag of the image to deploy — set by CI to the commit SHA."
  type        = string
  default     = "latest"
}

variable "job_cron_schedule" {
  description = "Cron expression controlling how often the governance check job runs."
  type        = string
  default     = "0 6 * * *" # daily at 06:00 UTC
}
