variable "project_id" {
  description = "The ID of the project in which the Firestore resources are created."
  type        = string
}

variable "databases" {
  description = "Map of Firestore databases to create. When provided, all multi-database resources are created for each database."
  type = map(object({
    database_id                        = string
    location                           = string
    database_type                      = optional(string, "FIRESTORE_NATIVE")
    database_edition                   = optional(string, "STANDARD")
    concurrency_mode                   = optional(string, "PESSIMISTIC")
    delete_protection_state            = optional(string, "DELETE_PROTECTION_ENABLED")
    point_in_time_recovery_enablement  = optional(string, "POINT_IN_TIME_RECOVERY_ENABLED")
    deletion_policy                    = optional(string, "DELETE")
    kms_key_name                       = optional(string)
    backup_schedule_configuration      = optional(any)
    field_configuration                = optional(list(any))
    composite_index_configuration      = optional(list(any))
  }))
  default = {}
}
