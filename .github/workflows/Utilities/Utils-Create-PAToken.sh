az config set extension.use_dynamic_install=yes_without_prompt


echo "ClientID: $ARM_CLIENT_ID"
echo "Client Secret: $ARM_CLIENT_SECRET"
echo "Tenant ID: $ARM_TENANT_ID"

# Log In To Databricks SPN To Interact With Databricks Environment
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

azKeyVaultName=$(az keyvault list -g $param_ResourceGroupName --query "[].name" -o tsv)
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


secretName="dbkstoken"
# Check if secret exists
secret_exists=$(az keyvault secret list --vault-name $keyVaultName --query "contains([].id, 'https://$keyVaultName.vault.azure.net/secrets/$secretName')")

if [ $secret_exists == true ]; then
    echo "Secret '$secretName' exists! fetching..."
    secret_val=$(az keyvault secret show --name $secretName --vault-name $keyVaultName --query "value")
else
    echo "Secret '$secretName' do not exist! creating PAT Token & Store In Key Vault..."
    
    # Create PAT token valid for 5 min (300 sec)
    # Must Assign SP Minimum Contributor Permissions. Must also give the SP Key Vault Administrator Privileges (Need to Set these in YAML)
    # Also note the PAT Token Will Expire, need to be able to recycle them
    
    #pat_token_response=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" -d '{"lifetime_seconds": 3000,"comment": "this is an example token"}' https://$workspaceUrl/api/2.0/token/create )
    
    pat_token_response=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" -d \
    '{
        "lifetime_seconds": "300000", 
        "comment": "Token For Databricks"
    }' https://$workspaceUrl/api/2.0/token/create )

    echo "pat_token_response: $pat_token_response" 

    # Print PAT token
    pat_token=$(jq .token_value -r <<< "$pat_token_response")
    echo $pat_token

    # Store PAT Token In Key Vault
    az keyvault secret set --vault-name $azKeyVaultName --name "dbkstoken" --value $pat_token
fi


