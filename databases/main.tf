/**
 * Wrapper module for managing multiple Firestore databases
 * 
 * This wrapper calls the root module multiple times using for_each,
 * enabling deployment of multiple databases in a single plan.
 * The root module remains unchanged and is reused for each database.
 */

module "firestore_databases" {
  for_each = var.databases

  source = "../"

  project_id                        = var.project_id
  database_id                       = each.value.database_id
  location                          = each.value.location
  database_type                     = each.value.database_type
  database_edition                  = each.value.database_edition
  concurrency_mode                  = each.value.concurrency_mode
  delete_protection_state           = each.value.delete_protection_state
  point_in_time_recovery_enablement = each.value.point_in_time_recovery_enablement
  deletion_policy                   = each.value.deletion_policy
  kms_key_name                      = each.value.kms_key_name
  backup_schedule_configuration     = each.value.backup_schedule_configuration
  field_configuration               = each.value.field_configuration
  composite_index_configuration     = each.value.composite_index_configuration
}
