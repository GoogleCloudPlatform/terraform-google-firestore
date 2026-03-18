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

output "database_resource_id" {
  description = "The database id of the firestore database."
  value       = var.database_id
}

output "database_id" {
  description = "The full database resource name of the firestore database, in the format projects/{{project_id}}/databases/{{name}}"
  value       = google_firestore_database.firestore_database.id
}

output "daily_backup_schedule_id" {
  description = "The unique backup schedule identifier across all locations and databases for the given project."
  value       = length(google_firestore_backup_schedule.daily_backup_schedule) > 0 ? google_firestore_backup_schedule.daily_backup_schedule[0].id : null
}

output "weekly_backup_schedule_id" {
  description = "The unique backup schedule identifier across all locations and databases for the given project."
  value       = length(google_firestore_backup_schedule.weekly_backup_schedule) > 0 ? google_firestore_backup_schedule.weekly_backup_schedule[0].id : null
}

output "composite_index_ids" {
  description = "List of composite indices for the firestore database."
  value       = tolist(values(google_firestore_index.firestore_index)[*].id)
}

output "field_ids" {
  description = "List of firestore fields created for the database."
  value       = tolist(values(google_firestore_field.firestore_field)[*].id)
}
