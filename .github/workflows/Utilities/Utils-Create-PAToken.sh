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
echo "Databricks WS RG:                         $azKeyVaultName"

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


# get Command Line Args
keyVaultName=$azKeyVaultName
secretName="dbkstoken"
echo ' secretName secretName: $secretName'

# Check if secret exists
secret_exists=$(az keyvault secret list --vault-name $keyVaultName --query "contains([].id, 'https://$keyVaultName.vault.azure.net/secrets/$secretName')")
echo ' Secrect Exists: $secret_exists'


if [ $secret_exists == true ]; then
    echo "Secret '$secretName' exists! fetching..."
    secret_val=$(az keyvault secret show --name $secretName --vault-name $keyVaultName --query "value")
else
    echo "Secret '$secretName' do not exist! creating PAT Token & Store In Key Vault..."
    
    # Create PAT token valid for 5 min (300 sec)
    # Must Assign SP Minimum Contributor Permissions. Must also give the SP Key Vault Administrator Privileges (Need to Set these in YAML)
    # Also note the PAT Token Will Expire, need to be able to recycle them
    
    #pat_token_response=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -d '{"lifetime_seconds": 3000,"comment": "this is an example token"}' https://$workspaceUrl/api/2.0/token/create )
    
    pat_token_response=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -d \
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


echo "##vso[task.setvariable variable=workspaceUrl]$workspaceUrl"
echo "##vso[task.setvariable variable=wsId]$wsId"