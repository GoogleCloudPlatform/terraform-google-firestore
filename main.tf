/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_firestore_database" "firestore_database" {
  project                           = var.project_id
  name                              = var.database_id
  location_id                       = var.location
  type                              = var.database_type
  concurrency_mode                  = var.concurrency_mode
  delete_protection_state           = var.delete_protection_state
  point_in_time_recovery_enablement = var.point_in_time_recovery_enablement
  database_edition                  = var.database_edition
  deletion_policy                   = var.deletion_policy

  dynamic "cmek_config" {
    for_each = var.kms_key_name != null ? [var.kms_key_name] : []
    content {
      kms_key_name = cmek_config.value
    }
  }
}

resource "google_firestore_backup_schedule" "weekly_backup_schedule" {
  count     = try(var.backup_schedule_configuration.weekly_recurrence != null, false) ? 1 : 0
  project   = var.project_id
  database  = google_firestore_database.firestore_database.name
  retention = var.backup_schedule_configuration.weekly_recurrence.retention

  weekly_recurrence {
    day = var.backup_schedule_configuration.weekly_recurrence.day
  }
}

resource "google_firestore_backup_schedule" "daily_backup_schedule" {
  count     = try(var.backup_schedule_configuration.daily_recurrence != null, false) ? 1 : 0
  project   = var.project_id
  database  = google_firestore_database.firestore_database.name
  retention = var.backup_schedule_configuration.daily_recurrence.retention
  daily_recurrence {}
  depends_on = [google_firestore_backup_schedule.weekly_backup_schedule]
}


resource "google_firestore_index" "firestore_index" {
  for_each    = { for obj in var.composite_index_configuration : obj.index_id => obj }
  project     = var.project_id
  database    = google_firestore_database.firestore_database.name
  collection  = each.value.collection
  query_scope = each.value.query_scope
  api_scope   = each.value.api_scope
  density     = each.value.density
  multikey    = each.value.multikey

  dynamic "fields" {
    for_each = each.value.fields
    content {
      field_path   = fields.value.field_path
      order        = fields.value.order
      array_config = fields.value.array_config
      dynamic "vector_config" {
        for_each = fields.value.vector_config != null ? [fields.value.vector_config] : []
        content {
          dimension = vector_config.value.dimension
          flat {}
        }
      }
    }
  }
}

resource "google_firestore_field" "firestore_field" {
  for_each   = { for obj in var.field_configuration : "${obj.collection}#${obj.field}" => obj }
  project    = var.project_id
  database   = google_firestore_database.firestore_database.name
  collection = each.value.collection
  field      = each.value.field

  dynamic "ttl_config" {
    for_each = each.value.ttl_enabled ? [1] : []
    content {}
  }

  index_config {
    dynamic "indexes" {
      for_each = each.value.ascending_index_query_scope
      content {
        order       = "ASCENDING"
        query_scope = indexes.value
      }
    }

    dynamic "indexes" {
      for_each = each.value.descending_index_query_scope
      content {
        order       = "DESCENDING"
        query_scope = indexes.value
      }
    }

    dynamic "indexes" {
      for_each = each.value.array_index_query_scope
      content {
        array_config = "CONTAINS"
        query_scope  = indexes.value
      }
    }
  }
}
