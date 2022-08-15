#!/bin/bash


# I have left the "Path" out as it doesn't seem to work. I think it might be permissions issue. States 'Resource is not found'. 
# I wonder if this is because Devops PAT token was used for git configuring the service principal.

echo "Ingest JSON File"

#Based on DBX Repo Folders Created in Parameters File Within Objection Repo_Configuration 
REPO_FOLDERS=("DevelopmentFolder"
"TestFolder"
"ProductionFolder")

for REPO_FOLDER in "${REPO_FOLDERS[@]}"; do
    echo "Git Pull On Repo Folder: $REPO_FOLDER"
    
    REPOS_WITH_MANAGEMENT_PERMISSIONS=$(curl -X GET \
                        -H "Authorization: Bearer $TOKEN" \
                        -H "X-Databricks-Azure-SP-Management-Token: $MGMT_ACCESS_TOKEN" \
                        -H "X-Databricks-Azure-Workspace-Resource-Id: $WORKSPACE_ID" \
                        -H 'Content-Type: application/json' \
                        https://$DATABRICKS_INSTANCE/api/2.0/repos )

    
    echo "Display Repos In DBX With Manage Permissions...."
    echo $REPOS_WITH_MANAGEMENT_PERMISSIONS

    echo "Ingest JSON File..."
    JSON=$( jq '.' .github/workflows/Pipeline_Param/$environment.json)
    #echo "${JSON}" | jq

    echo "Retrieve Repo ID For $REPO_FOLDER..."
    REPO_ID=$( jq -r --arg REPO_FOLDER "$REPO_FOLDER" ' .repos[] | select( .path | contains($REPO_FOLDER)) | .id ' <<< "$REPOS_WITH_MANAGEMENT_PERMISSIONS")
    
    echo "Repo ID: $REPO_ID"

    echo "With Repo ID, Retrieve Associated Branch For $REPO_FOLDER"
    BRANCH=$( jq -r --arg REPO_FOLDER "$REPO_FOLDER" ' .Repo_Configuration[] | select( .path | contains($REPO_FOLDER)) | .branch ' <<< "$JSON")
    
    echo "$REPO_FOLDER Associated With $BRANCH Branch"

    JSON_STRING=$( jq -n -c --arg tb "$BRANCH" \
                '{branch: $tb}' )

    echo "Git Pull on DBX Repo $REPO_FOLDER With $BRANCH Branch "
    GIT_PULL_RESPONSE=$(curl -X PATCH \
        -H "Authorization: Bearer $TOKEN" \
        -H "X-Databricks-Azure-SP-Management-Token: $MGMT_ACCESS_TOKEN" \
        -H "X-Databricks-Azure-Workspace-Resource-Id: $WORKSPACE_ID" \
        -H 'Content-Type: application/json' \
        -d $JSON_STRING \
        https://$DATABRICKS_INSTANCE/api/2.0/repos/$REPO_ID )
    
    echo "Git Pull Response..."
    echo $GIT_PULL_RESPONSE
done








#echo $environment

#RepoID=$( jq -r '.repos[] | select( .path | contains($Development)) | .id' <<< "$reposWithManagePermissions")
#echo "Target Branch == Main"
#echo $RepoID


#json=$( jq '.' .github/workflows/Global_Parameters/$environment.json)
#echo "${json}" | jq
#branch=$( jq -r  ' .Repo_Configuration[]| select( .path | contains("Development"))| .branch ' <<< "$json")


#JSON_STRING=$( jq -n -c \
#                --arg tb "$branch" \
#                '{branch: $tb}' )

#echo $JSON_STRING

# If there is a change to the develop branch, we will update Files in the Staging/Test Folder
#update_repo_response=$(curl -X PATCH \
#        -H "Authorization: Bearer $token" \
#        -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
#        -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
#        -H 'Content-Type: application/json' \
#        -d $JSON_STRING \
#        https://$workspaceUrl/api/2.0/repos/$RepoID )

#echo $update_repo_response



