az config set extension.use_dynamic_install=yes_without_prompt
azKeyVaultName=$(az keyvault list -g $param_ResourceGroupName --query "[].name" -o tsv)
dbx_workspace_name=$(az databricks workspace list -g $param_ResourceGroupName --query "[].name" -o tsv)
workspaceUrl=$(az databricks workspace list -g $param_ResourceGroupName --query "[].workspaceUrl" -o tsv)
workspace_id=$(az databricks workspace list -g $param_ResourceGroupName --query "[].id" -o tsv)


secretName="dbkstoken"
# Check if secret exists
secret_exists=$(az keyvault secret list --vault-name $azKeyVaultName --query "contains([].id, 'https://$azKeyVaultName.vault.azure.net/secrets/$secretName')")
echo "secret exists: $secret_exists"

if [ $secret_exists == true ]; then
    echo "Secret '$secretName' exists! fetching..."
    secret_val=$(az keyvault secret show --name $secretName --vault-name $azKeyVaultName --query "value")
    echo "Secret Value: $secret_val"
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


