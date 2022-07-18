az config set extension.use_dynamic_install=yes_without_prompt

echo "ClientID: $ARM_CLIENT_ID"
echo "Client Secret: $ARM_CLIENT_SECRET"
echo "Tenant ID: $ARM_TENANT_ID"

echo "Logging in using Azure service priciple"
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

dbx_workspace_name=$(az databricks workspace list -g $param_ResourceGroupName --query "[].name" -o tsv)
workspaceUrl=$(az databricks workspace list -g $param_ResourceGroupName --query "[].workspaceUrl" -o tsv)
workspace_id=$(az databricks workspace list -g $param_ResourceGroupName --query "[].id" -o tsv)

# token response for the azure databricks app  
token_response=$(az account get-access-token --resource $param_AZURE_DATABRICKS_APP_ID)
echo "Token response: $token_response"

# Extract accessToken value --> We use 'Here Strings to turn the JSON token response into an Array, and then extract the accessToken'
token=$(jq .accessToken -r <<< "$token_response")
echo "Token: $token"

az_mgmt_resource_endpoint=$(curl -X GET -H 'Content-Type: application/x-www-form-urlencoded' -d 'grant_type=client_credentials&client_id='$ARM_CLIENT_ID'&resource='$param_MANAGEMENT_RESOURCE_ENDPOINT'&client_secret='$ARM_CLIENT_SECRET https://login.microsoftonline.com/$ARM_TENANT_ID/oauth2/token)
echo "Management Resource Endpoint: $az_mgmt_resource_endpoint"

# Extract the access_token value
mgmt_access_token=$(jq .access_token -r <<< "$az_mgmt_resource_endpoint" )
echo "Management Access Token: $mgmt_access_token"


echo "Create DBX Service Principal Scope"
Create_Secret_Scope=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" -H 'Content-Type: application/json' -d \
'{
"scope": "DBX_SP_Credentials", 
"initial_manage_principal": "users" 
}' https://$workspaceUrl/api/2.0/secrets/scopes/create )
echo $Create_Secret_Scope 

# Insert DBX Client Secret, ClientID and TenantID into the Secret Scope.
# Why?... Within A Python Script, We Can Use The DBUTILS To Retrive The Service Principal Credential...
# And Authenticate. The DBX SP Has RBACS Assigned To Key Vault/ Resoures...

Create_DBX_Client_Secret=$(curl -X POST -H "Authorization: Bearer $token" \
                        -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
                        -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
                        -H 'Content-Type: application/json' 
                        -d \
                        '{
                        "scope": "DBX_SP_Credentials", 
                        "key": "DBX_SP_Client_Secret",
                        "string_value": "$ARM_CLIENT_SECRET"
                        }' https://$workspaceUrl/api/2.0/secrets/put )
echo $Create_Client_Secret

Create_DBX_ClientID=$(curl -X POST -H "Authorization: Bearer $token" \
                        -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
                        -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
                        -H 'Content-Type: application/json' 
                        -d \
                        '{
                        "scope": "DBX_SP_Credentials", 
                        "key": "DBX_SP_ClientID",
                        "string_value": "$ARM_CLIENT_ID"
                        }' https://$workspaceUrl/api/2.0/secrets/put )
echo $Create_DBX_ClientID

Create_DBX_TenantID=$(curl -X POST -H "Authorization: Bearer $token" \
                        -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
                        -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
                        -H 'Content-Type: application/json' 
                        -d \
                        '{
                        "scope": "DBX_SP_Credentials", 
                        "key": "DBX_SP_TenantID",
                        "string_value": "$ARM_TENANT_ID"
                        }' https://$workspaceUrl/api/2.0/secrets/put )
echo $Create_DBX_TenantID


