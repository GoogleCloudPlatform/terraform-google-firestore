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

module "firestore" {
  source                            = "GoogleCloudPlatform/firestore/google"
  version                           = "0.0.1"
  project_id                        = var.project_id
  database_id                       = "terraform-blueprint-backup-test"
  location                          = "us-central1"
  database_type                     = "FIRESTORE_NATIVE"
  concurrency_mode                  = "OPTIMISTIC"
  delete_protection_state           = "DELETE_PROTECTION_DISABLED"
  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_DISABLED"
  deletion_policy                   = "DELETE"
  backup_schedule_configuration = {
    weekly_recurrence = {
      day       = "MONDAY",
      retention = "2419200s"
    }

    daily_recurrence = {
      retention = "1209600s"
    }
  }
}
