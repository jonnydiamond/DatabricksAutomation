#  .d8888b.  8888888b.               d8888          888    888                        888    d8b                   888             
# d88P  Y88b 888   Y88b             d88888          888    888                        888    Y8P                   888             
# Y88b.      888    888            d88P888          888    888                        888                          888             
#  "Y888b.   888   d88P           d88P 888 888  888 888888 88888b.   .d88b.  88888b.  888888 888  .d8888b  8888b.  888888  .d88b.  
#     "Y88b. 8888888P"           d88P  888 888  888 888    888 "88b d8P  Y8b 888 "88b 888    888 d88P"        "88b 888    d8P  Y8b 
#       "888 888                d88P   888 888  888 888    888  888 88888888 888  888 888    888 888      .d888888 888    88888888 
# Y88b  d88P 888               d8888888888 Y88b 888 Y88b.  888  888 Y8b.     888  888 Y88b.  888 Y88b.    888  888 Y88b.  Y8b.     
#  "Y8888P"  888              d88P     888  "Y88888  "Y888 888  888  "Y8888  888  888  "Y888 888  "Y8888P "Y888888  "Y888  "Y8888  
####################################################################################################################################################################
set -o errexit
set -o nounset
set -o pipefail


echo "Logging in using Azure service principal"
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# az account set -s  $ARM_SUBSCRIPTION_ID
echo 'ClientSecret:                             $ARM_CLIENT_SECRET'
echo 'ClientID:                                 $ARM_CLIENT_ID'
echo 'TenantID:                                 $ARM_TENANT_ID'
echo 'ApplicationID                             $AZURE_DATABRICKS_APP_ID'
echo 'DatabricksWorkspace:                      $DATABRICKS_WORKSPACE'
echo 'Databricks WS RG:                         $RESOURCE_GROUP'
echo 'Token:                                    $(dbkstoken)'
echo 'Host:                                     $(workspaceUrl)'
echo 'WorkspaceID:                              $(wsId)'

# Enable install of extensions without prompt
az config set extension.use_dynamic_install=yes_without_prompt
wsId=$(az resource show --resource-type Microsoft.Databricks/workspaces -g $RESOURCE_GROUP -n "$DATABRICKS_WORKSPACE" --query id -o tsv)
echo "Workspce ID: $wsId"

# Get workspace url e.g. adb-xxxxxxxxxxxxxxxx.x.azuredatabricks.net
workspaceUrl=$(az resource show --resource-type Microsoft.Databricks/workspaces -g "$RESOURCE_GROUP" -n "$DATABRICKS_WORKSPACE" --query properties.workspaceUrl --output tsv)
echo "Workspce URL: $workspaceUrl" # example --> adb-2427722425237209.9.azuredatabricks.net

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