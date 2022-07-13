set -o errexit
set -o nounset
set -o pipefail

# Login using service principle
echo "Logging in using Azure service priciple"

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


echo "create secret scope"
createSecretScope=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
'{
"scope": "scopestgacckey", 
"initial_manage_principal": "users" 
}' https://$workspaceUrl/api/2.0/secrets/scopes/create )


echo $createSecretScope 


listSecretScope=$(curl -X GET -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' https://$workspaceUrl/api/2.0/secrets/scopes/list )

echo $listSecretScope 


# I have left the "Path" out as it doesn't seem to work. I think it might be permissions issue. States 'Resource is not found'. I wonder if this is because Devops PAT token was used for git configuring the service principal.

createAppIDSecret=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
'{
"scope": "scopestgacckey", 
"key": "serviceprincipal-databricks-sp-dbw-dap-AppID",
"string_value": "$AZURE_DATABRICKS_APP_ID"
}' https://$workspaceUrl/api/2.0/secrets/put )

echo $createAppIDSecret

createDBXClientSecret=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
'{
"scope": "scopestgacckey", 
"key": "serviceprincipal-databricks-sp-dbw-dap-Password",
"string_value": "$ARM_CLIENT_SECRET"
}' https://$workspaceUrl/api/2.0/secrets/put )

echo $createDBXClientSecret