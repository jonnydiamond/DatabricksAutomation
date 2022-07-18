az config set extension.use_dynamic_install=yes_without_prompt
dbx_workspace_name=$(az databricks workspace list -g $param_ResourceGroupName --query "[].name" -o tsv)
workspaceUrl=$(az databricks workspace list -g $param_ResourceGroupName --query "[].workspaceUrl" -o tsv)
workspace_id=$(az databricks workspace list -g $param_ResourceGroupName --query "[].id" -o tsv)


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
                -H 'Content-Type: application/json' -d \
                '{
                "scope": "DBX_SP_Credentials", 
                "key": "DBX_SP_Client_Secret",
                "string_value": "$ARM_CLIENT_SECRET"
                }' https://$workspaceUrl/api/2.0/secrets/put )

Create_DBX_ClientID=$(curl -X POST -H "Authorization: Bearer $token" \
                -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
                -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
                -H 'Content-Type: application/json' -d \
                '{
                "scope": "DBX_SP_Credentials", 
                "key": "DBX_SP_ClientID",
                "string_value": "$ARM_CLIENT_ID"
                }' https://$workspaceUrl/api/2.0/secrets/put )

Create_DBX_TenantID=$(curl -X POST -H "Authorization: Bearer $token" \
                -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
                -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
                -H 'Content-Type: application/json' -d \
                '{
                "scope": "DBX_SP_Credentials", 
                "key": "DBX_SP_TenantID",
                "string_value": "$ARM_TENANT_ID"
                }' https://$workspaceUrl/api/2.0/secrets/put )



