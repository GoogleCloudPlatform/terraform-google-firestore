// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package firestore_resource

import (
	"encoding/json"
	"fmt"
	"regexp"
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

type IndexInfo struct {
	Fields     []IndexField `json:"fields"`
	Name       string       `json:"name"`
	QueryScope string       `json:"queryScope"`
	ApiScope   string       `json:"apiScope"`
	State      string       `json:"state"`
	Density    string       `json:"density"`
}

type IndexField struct {
	FieldPath string `json:"fieldPath"`
	Order     string `json:"order"`
}

func extractCollectionGroupName(indexName string) string {
	re := regexp.MustCompile(`projects/[^/]+/databases/[^/]+/collectionGroups/([^/]+)/indexes/[^/]+`)
	match := re.FindStringSubmatch(indexName)
	if len(match) == 2 {
		return match[1]
	}

	return ""
}

func TestExampleWithEnterpriseEditionAndIndexes(t *testing.T) {
	example := tft.NewTFBlueprintTest(t)

	example.DefineVerify(func(assert *assert.Assertions) {
		example.DefaultVerify(assert)

		projectId := example.GetTFSetupStringOutput("project_id")
		databaseId := example.GetStringOutput("database_id")

		databaseIdPrefix := fmt.Sprintf("projects/%s/databases/", projectId)
		databaseName := strings.TrimPrefix(databaseId, databaseIdPrefix)

		databaseInfo := gcloud.Run(
			t,
			"firestore databases describe",
			gcloud.WithCommonArgs([]string{"--project", projectId, "--database", databaseName, "--format", "json"}),
		)

		indexInfo := gcloud.Run(
			t,
			"firestore indexes composite list",
			gcloud.WithCommonArgs([]string{"--project", projectId, "--database", databaseName, "--format", "json"}),
		).String()

		var indexList []IndexInfo
		json.Unmarshal([]byte(indexInfo), &indexList)

		expectedIndexes := make(map[string][][]IndexField)
		expectedIndexes["test-collection-1"] = [][]IndexField{
			[]IndexField{
				IndexField{
					FieldPath: "field1",
					Order:     "ASCENDING",
				},
				IndexField{
					FieldPath: "field2",
					Order:     "DESCENDING",
				},
			},
		}

		expectedIndexes["test-collection-2"] = [][]IndexField{
			[]IndexField{
				IndexField{
					FieldPath: "field3",
					Order:     "ASCENDING",
				},
			},
		}

		assert.Equal(
			databaseId,
			databaseInfo.Get("name").String(),
			"Database ID does not match.",
		)

		assert.Equal(
			"ENTERPRISE",
			databaseInfo.Get("databaseEdition").String(),
			"Expected enterprise database edition.",
		)

		assert.Equal(
			"FIRESTORE_NATIVE",
			databaseInfo.Get("type").String(),
			"Expected firestore native database.",
		)

		assert.Equal(
			"us-central1",
			databaseInfo.Get("locationId").String(),
			"Expected database to be created in us-central1 region.",
		)

		assert.Equal(
			"PESSIMISTIC",
			databaseInfo.Get("concurrencyMode").String(),
			"Expected pessimistic concurrency mode.",
		)

		assert.Equal(
			2,
			len(indexList),
		)

		actualIndexes := make(map[string][][]IndexField)
		for _, index := range indexList {
			assert.Equal(
				"COLLECTION_GROUP",
				index.QueryScope,
			)

			assert.Equal(
				"MONGODB_COMPATIBLE_API",
				index.ApiScope,
			)

			assert.Equal(
				"DENSE",
				index.Density,
			)

			collectionGroupName := extractCollectionGroupName(index.Name)
			_, ok := actualIndexes[collectionGroupName]
			if !ok {
				actualIndexes[collectionGroupName] = [][]IndexField{}
			}

			actualIndexes[collectionGroupName] = append(actualIndexes[collectionGroupName], index.Fields)
		}

		assert.Equal(
			1,
			len(actualIndexes["test-collection-1"]),
		)

		assert.Equal(
			1,
			len(actualIndexes["test-collection-2"]),
		)

		assert.Equal(
			expectedIndexes["test-collection-1"],
			actualIndexes["test-collection-1"],
		)

		assert.Equal(
			expectedIndexes["test-collection-2"],
			actualIndexes["test-collection-2"],
		)

	})
	example.Test()
}
