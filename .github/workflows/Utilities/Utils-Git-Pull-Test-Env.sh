
REPOS_WITH_MANAGEMENT_PERMISSIONS=$(curl -X GET \
                -H "Authorization: Bearer $TOKEN" \
                -H "X-Databricks-Azure-SP-Management-Token: $MGMT_ACCESS_TOKEN" \
                -H "X-Databricks-Azure-Workspace-Resource-Id: $WORKSPACE_ID" \
                -H 'Content-Type: application/json' \
                https://$DATABRICKS_INSTANCE/api/2.0/repos )

echo "Display Repos In DBX With Manage Permissions...."
echo $REPOS_WITH_MANAGEMENT_PERMISSIONS

echo "Retrieve Repo ID For TestFolder..."
REPO_ID=$( jq -r ' .repos[] | select( .path | contains("TestFolder")) | .id ' <<< "$REPOS_WITH_MANAGEMENT_PERMISSIONS")

echo "Repo ID: $REPO_ID"

echo "Git Pull on DBX Repo TestFolder With Main Branch "

JSON_STRING=$( jq -n -c --arg tb "$BRANCH" \
        '{branch: $tb}' )

GIT_PULL_RESPONSE=$(curl -X PATCH \
-H "Authorization: Bearer $TOKEN" \
-H "X-Databricks-Azure-SP-Management-Token: $MGMT_ACCESS_TOKEN" \
-H "X-Databricks-Azure-Workspace-Resource-Id: $WORKSPACE_ID" \
-H 'Content-Type: application/json' \
-d $JSON_STRING \
https://$DATABRICKS_INSTANCE/api/2.0/repos/$REPO_ID )

echo "Git Pull Response..."
echo $GIT_PULL_RESPONSE
