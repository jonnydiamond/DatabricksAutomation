az config set extension.use_dynamic_install=yes_without_prompt

echo "ClientID: $ARM_CLIENT_ID"
echo "Client Secret: $ARM_CLIENT_SECRET"
echo "Tenant ID: $ARM_TENANT_ID"

echo "Logging in using Azure service priciple"
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

dbx_workspace_name=$(az databricks workspace list -g $param_ResourceGroupName --query "[].name" -o tsv)
workspaceUrl=$(az databricks workspace list -g $param_ResourceGroupName --query "[].workspaceUrl" -o tsv)
workspace_id=$(az databricks workspace list -g $param_ResourceGroupName --query "[].id" -o tsv)

echo "workspace_id=$workspace_id" >> $GITHUB_ENV
echo "Workspace ID Set As Env Variable: $workspace_id"

echo "workspaceUrl=$workspaceUrl" >> $GITHUB_ENV
echo "Workspace URL Set As Env Variable: $workspaceUrl"

# token response for the azure databricks app  
token_response=$(az account get-access-token --resource $param_AZURE_DATABRICKS_APP_ID)
echo "Token response: $token_response"
echo "Management Access Set As Env Variable: $Management_Access_Token"

# Extract accessToken value --> We use 'Here Strings to turn the JSON token response into an Array, and then extract the accessToken'
token=$(jq .accessToken -r <<< "$token_response")
echo "Token: $token"
echo "Token=$token" >> $GITHUB_ENV
echo "Token Set As Env Variable: $Token"

az_mgmt_resource_endpoint=$(curl -X GET -H 'Content-Type: application/x-www-form-urlencoded' -d 'grant_type=client_credentials&client_id='$ARM_CLIENT_ID'&resource='$param_MANAGEMENT_RESOURCE_ENDPOINT'&client_secret='$ARM_CLIENT_SECRET https://login.microsoftonline.com/$ARM_TENANT_ID/oauth2/token)
echo "Management Resource Endpoint: $az_mgmt_resource_endpoint"

# Extract the access_token value
mgmt_access_token=$(jq .access_token -r <<< "$az_mgmt_resource_endpoint" )
echo "Management Access Token: $mgmt_access_token"
echo "Management_Access_Token=$mgmt_access_token" >> $GITHUB_ENV
echo "Management Access Set As Env Variable: $Management_Access_Token"