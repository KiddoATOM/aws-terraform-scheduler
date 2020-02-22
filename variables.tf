# General variables

variable "environment" {
  description = "Environment for wich this module will be created. E.g. Development"
  type        = string
  default     = "Development"
}

variable "custom_tags" {
  description = "Optional tags to be applied on top of the base tags on all resources"
  type        = map(string)
  default     = {}
}

# Lambda monitor billing variables
variable "scheduler_tag_name" {
  description = "Tag name to use as filter for lambda scheduler."
  type        = string
  default     = "Scheduler"
}

variable "scheduler_tag_value" {
  description = "Tag value to use as filter for lambda scheduler."
  type        = string
  default     = "true"
}

variable "repositories" {
  description = "List of repositories to clean up by lambda scheduler. Comma separated names of the repositories to clean."
  type        = string
  default     = ""
}

variable "buckets" {
  description = "List of buckets to clean up by lambda scheduler. Comma separated names of the repositories to clean."
  type        = string
  default     = ""
}

variable "start_time" {
  description = "Schedule expression when instance will be started."
  type        = string
  default     = "cron(0 8 ? * MON-FRI *)"
}

variable "stop_time" {
  description = "Schedule expression when instance will be stoped and repositores clean"
  default     = "cron(0 19 ? * MON-FRI *)"
  type        = string
}

variable "log_retention" {
  description = "Specifies the number of days you want to retain log events in the specified log group."
  type        = number
  default     = 14
}

