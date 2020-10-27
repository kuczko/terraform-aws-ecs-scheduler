variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "name" {
  type        = string
  default     = ""
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "stage" {
  type        = string
  default     = ""
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "cron_start" {
  type        = string
  default     = ""
  description = "Cloudwatch rule cron expression to start tasks"
}

variable "cron_stop" {
  type        = string
  default     = ""
  description = "Cloudwatch rule cron expression to stop tasks"
}

variable "cluster_name" {
  type        = string
  description = "ECS cluster name"
}

variable "region" {
  type        = string
  description = "Region where ecs cluster is hosted"
}

variable "ecs_services" {
  type        = list(
                  object({
                    service_name  = string
                    desired_count = string
                  })
                )
  default = []
  description = "List of services to be scheduled and their default desired count when active"
}
