#################
# Configuration #
#################
variable "vpc_name" {
  description = "The name of the vpc (eg.: live-1)"
  type        = string
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
  type        = string
}

variable "advanced_options" {
  description = "Key-value string pairs to specify advanced configuration options"
  type        = map(string)
  default     = {}
}

variable "cluster_config" {
  description = "Configuration block for the cluster of the domain"
  type        = map(any)
  default     = {}
}

variable "engine_version" {
  description = "OpenSearch engine version"
  type        = string
}

variable "proxy_count" {
  description = "Replica count for OpenSearch proxy"
  type        = number
  default     = 1
}

########
# Tags #
########
variable "business_unit" {
  description = "Area of the MOJ responsible for the service"
  type        = string
}

variable "application" {
  description = "Application name"
  type        = string
}

variable "is_production" {
  description = "Whether this is used for production or not"
  type        = string
}

variable "team_name" {
  description = "Team name"
  type        = string
}

variable "namespace" {
  description = "Namespace name"
  type        = string
}

variable "environment_name" {
  description = "Environment name"
  type        = string
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form <team-name> (<team-email>)"
  type        = string
}
