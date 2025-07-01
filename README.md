# terraform-google-firestore

## Description
### Tagline
This terraform module is used to create a [Cloud Firestore](https://cloud.google.com/products/firestore) database

### Detailed
The resources/services/activations/deletions that this module will create/trigger are:

- Creates a Cloud Firestore database.
- Creates a daily/weekly backup schedule for the Firestore database.
- Creates composite indexes for the database.
- Creates single fields exempt from default indexing for the database.

## Usage
Basic usage of this module is as follows:

```hcl
module "firestore_infra" {
  source = "terraform-google-modules/firestore/google"
  project_id = "<PROJECT_ID>"
  database_id = "firestore-test-db"
  location_id = "us-central1"
  database_type = "FIRESTORE_NATIVE"
  concurrency_mode = "OPTIMISTIC"
  delete_protection_state = "DELETE_PROTECTION_DISABLED"
  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_DISABLED"
  deletion_policy = "ABANDON"
  backup_schedule_configuration = {
    daily_recurrence = {}
    retention = "2419200s"
  }

  composite_index_configuration = [
    {
      index_id = "my-index1"
      collection = "terraform-firestore-collection"
      query_scope = "COLLECTION"
      api_scope = "ANY_API"
      fields = [
        {
          field_path = "field1"
          order = "ASCENDING"
        },
        {
          field_path = "field2"
          order = "DESCENDING"
        }
      ]
    }
  ]

  field_configuration = [
    {
      collection = "reviews"
      field = "field3"
      ascending_index_query_scope = ["COLLECTION_GROUP"]
      descending_index_query_scope = ["COLLECTION_GROUP"]
      array_index_query_scope = ["COLLECTION"]
    },
    {
      collection = "reviews"
      field = "field4"
      ascending_index_query_scope = ["COLLECTION_GROUP", "COLLECTION_GROUP"]
    }
  ]
}

```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backup\_schedule\_configuration | Backup schedule configuration for the Firestore Database. | <pre>object({<br>    weekly_recurrence = optional(object({<br>      day       = string<br>      retention = string<br>    }))<br><br>    daily_recurrence = optional(object({<br>      retention = string<br>    }))<br>  })</pre> | `null` | no |
| composite\_index\_configuration | Composite index configuration for the Firestore Database. | <pre>list(object({<br>    index_id    = string<br>    collection  = string<br>    query_scope = optional(string, "COLLECTION")<br>    api_scope   = optional(string, "ANY_API")<br>    density     = optional(string)<br>    multikey    = optional(bool)<br>    fields = list(object({<br>      field_path   = string<br>      order        = optional(string)<br>      array_config = optional(string)<br>      vector_config = optional(object({<br>        dimension = number<br>      }))<br>    }))<br>  }))</pre> | `[]` | no |
| concurrency\_mode | Concurrency control mode to be used for the Firestore Database. | `string` | `"PESSIMISTIC"` | no |
| database\_edition | The database edition used to create the Firestore database. | `string` | `"STANDARD"` | no |
| database\_id | Unique identifier of the Firestore Database. | `string` | n/a | yes |
| database\_type | Database type used to created the Firestore Database. | `string` | `"FIRESTORE_NATIVE"` | no |
| delete\_protection\_state | Determines whether deletion protection is enabled or not for the Firestore Database. | `string` | `"DELETE_PROTECTION_ENABLED"` | no |
| deletion\_policy | Deletion policy enforced when Firestore Database is destroyed via Terraform. | `string` | `"DELETED"` | no |
| field\_configuration | Single field configurations for the Firestore Database. | <pre>list(object({<br>    collection                   = string<br>    field                        = string<br>    ttl_enabled                  = optional(bool, false)<br>    ascending_index_query_scope  = optional(set(string), [])<br>    descending_index_query_scope = optional(set(string), [])<br>    array_index_query_scope      = optional(set(string), [])<br>  }))</pre> | `[]` | no |
| kms\_key\_name | The resource ID of the Customer-managed Encryption Key (CMEK) using which the created database will be encrypted. | `string` | `null` | no |
| location | The location in which the Firesotre Database is created. | `string` | n/a | yes |
| point\_in\_time\_recovery\_enablement | Determines whether point-in-time recovery is enabled for the Firestore Database. | `string` | `"POINT_IN_TIME_RECOVERY_ENABLED"` | no |
| project\_id | The ID of the project in which the Firestore resources are created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| composite\_index\_ids | List of composite indices for the firestore database. |
| daily\_backup\_schedule\_id | The unique backup schedule identifier across all locations and databases for the given project. |
| database\_id | The database id of the firestore database. |
| field\_ids | List of firestore fields created for the database. |
| weekly\_backup\_schedule\_id | The unique backup schedule identifier across all locations and databases for the given project. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Storage Admin: `roles/storage.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Storage JSON API: `storage-api.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
