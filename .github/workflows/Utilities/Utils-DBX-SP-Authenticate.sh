az config set extension.use_dynamic_install=yes_without_prompt

echo "ClientID: $ARM_CLIENT_ID"
echo "Client Secret: $ARM_CLIENT_SECRET"
echo "Tenant ID: $ARM_TENANT_ID"

echo "Logging in using Azure service priciple"
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

### Remove This In Time
DATABRICKS_ORDGID=$(az databricks workspace list -g $param_ResourceGroupName --query "[].workspaceId" -o tsv)
DATABRICKS_INSTANCE="$(az databricks workspace list -g $param_ResourceGroupName --query "[].workspaceUrl" -o tsv)"
WORKSPACE_ID=$(az databricks workspace list -g $param_ResourceGroupName --query "[].id" -o tsv)
AZ_KEYVAULT_NAME=$(az keyvault list -g $param_ResourceGroupName --query "[].name" -o tsv)
DATABRICKS_TOKEN=$(az keyvault secret show --name "dbkstoken" --vault-name $AZ_KEYVAULT_NAME --query "value" -o tsv)
TOKEN_RESPONSE=$(az account get-access-token --resource $param_AZURE_DATABRICKS_APP_ID)
TOKEN=$(jq .accessToken -r <<< "$token_response")
AZ_MGMT_RESOURCE_ENDPOINT=$(curl -X GET -H 'Content-Type: application/x-www-form-urlencoded' \
                            -d 'grant_type=client_credentials&client_id='$ARM_CLIENT_ID'&resource='$param_MANAGEMENT_RESOURCE_ENDPOINT'&client_secret='$ARM_CLIENT_SECRET \
                            https://login.microsoftonline.com/$ARM_TENANT_ID/oauth2/token)
MGMT_ACCESS_TOKEN=$(jq .access_token -r <<< "$AZ_MGMT_RESOURCE_ENDPOINT" )


### Creation Of Important Environment Variables For Later Steps.
echo "Set Environment Variables For Later Stages..."

echo "Set Management Access Token As Environment Variable..."
echo "MGMT_ACCESS_TOKEN=$MGMT_ACCESS_TOKEN" >> $GITHUB_ENV

echo "Set Databricks Token As Environment Variable..."
echo "TOKEN=$TOKEN" >> $GITHUB_ENV

echo "Set Databricks OrgID As Environment Variable..."
echo "DATABRICKS_ORDGID=$DATABRICKS_ORDGID" >> $GITHUB_ENV

echo "Set Workspace ID As Environment Variable..."
echo "WORKSPACE_ID=$WORKSPACE_ID" >> $GITHUB_ENV

echo "Set Datbricks Instance As Environment Variable..."
echo "DATABRICKS_INSTANCE=$DATABRICKS_INSTANCE" >> $GITHUB_ENV

echo "Set Databricks Host As Environment Variable..."
echo "DATABRICKS_HOST=https://$DATABRICKS_INSTANCE" >> $GITHUB_ENV

echo "Set Databricks Token ID As Environment Variable..."
echo "DATABRICKS_TOKEN=$DATABRICKS_TOKEN" >> $GITHUB_ENV

echo "Set Python Path"
echo "PYTHONPATH=src/modules" >> $GITHUB_ENV