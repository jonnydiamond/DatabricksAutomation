set -o errexit
set -o nounset
set -o pipefail


echo "Logging in using Azure service principal"
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# az account set -s  $ARM_SUBSCRIPTION_ID
echo "ClientSecret:                             $ARM_CLIENT_SECRET"
echo "ClientID:                                 $ARM_CLIENT_ID"
echo "TenantID:                                 $ARM_TENANT_ID"
echo "Databricks WS RG:                         $RESOURCE_GROUP"
echo "workspace id                              $wsId"
echo "worokspace url                            $workspaceUrl"  
echo "APP ID                                    $AZURE_DATABRICKS_APP_ID"


# token response for the azure databricks app  
token_response=$(az account get-access-token --resource $AZURE_DATABRICKS_APP_ID)
echo "Token response: $token_response"

# Extract accessToken value --> We use 'Here Strings to turn the JSON token response into an Array, and then extract the accessToken'
token=$(jq .accessToken -r <<< "$token_response")
echo "Token: $token"

az_mgmt_resource_endpoint=$(curl -X GET -H 'Content-Type: application/x-www-form-urlencoded' -d 'grant_type=client_credentials&client_id='$ARM_CLIENT_ID'&resource='$MANAGEMENT_RESOURCE_ENDPOINT'&client_secret='$ARM_CLIENT_SECRET https://login.microsoftonline.com/$ARM_TENANT_ID/oauth2/token)
echo "Management Resource Endpoint: $az_mgmt_resource_endpoint"

# Extract the access_token value
mgmt_access_token=$(jq .access_token -r <<< "$az_mgmt_resource_endpoint" )
echo "Management Access Token: $mgmt_access_token"

git_credentials=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
'{
"personal_access_token": "yhdjjk6kcmmv6zcfowmsh6pmcre3jbstwbk5sarxcwtutmlyu5ha", 
"git_username": "ciaranh@microsoft.com", 
"git_provider": "azureDevOpsServices"
}' https://$workspaceUrl/api/2.0/git-credentials )

echo $git_credentials 

## The Section CREATES The Repos --> 3 Folders 'Production, Staging and Test' in the DBX Repo for the SP. This will be locked Down 
## When changes are merged into each branch, an automated pipeline run will update the repo.
## This will ensure that the branch for the testing /production repo is up to date when we run jobs on it.


create_repo_response=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
'{
"url": "https://dev.azure.com/ciaranh0658/_git/devopsTemplates", 
"provider": "azureDevOpsServices",
"path": "/Repos/ce79c2ef-170d-4f1c-a706-7814efb94898/Development"
}' https://$workspaceUrl/api/2.0/repos )

echo $create_repo_response

create_repo_response=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
'{
"url": "https://dev.azure.com/ciaranh0658/_git/devopsTemplates", 
"provider": "azureDevOpsServices",
"path": "/Repos/ce79c2ef-170d-4f1c-a706-7814efb94898/Production"
}' https://$workspaceUrl/api/2.0/repos )

echo $create_repo_response

create_repo_response=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
'{
"url": "https://dev.azure.com/ciaranh0658/_git/devopsTemplates", 
"provider": "azureDevOpsServices",
"path": "/Repos/ce79c2ef-170d-4f1c-a706-7814efb94898/Staging"
}' https://$workspaceUrl/api/2.0/repos )

echo $create_repo_response