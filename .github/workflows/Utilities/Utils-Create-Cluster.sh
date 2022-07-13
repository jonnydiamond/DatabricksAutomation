set -o errexit
set -o nounset
set -o pipefail

echo "Logging in using Azure service principal"
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# az account set -s  $ARM_SUBSCRIPTION_ID
echo "Environment Variables Test"
echo "ClientSecret:                             $ARM_CLIENT_SECRET"
echo "ClientID:                                 $ARM_CLIENT_ID"
echo "TenantID:                                 $ARM_TENANT_ID"
echo "Databricks WS RG:                         $RESOURCE_GROUP"
echo "workspace id                              $wsId"
echo "worokspace url                            $workspaceUrl"  
echo "APP ID                                    $AZURE_DATABRICKS_APP_ID"

# token response for the azure databricks app  
token_response=$(az account get-access-token --resource $AZURE_DATABRICKS_APP_ID)
token=$(jq .accessToken -r <<< "$token_response")
az_mgmt_resource_endpoint=$(curl -X GET -H 'Content-Type: application/x-www-form-urlencoded' -d 'grant_type=client_credentials&client_id='$ARM_CLIENT_ID'&resource='$MANAGEMENT_RESOURCE_ENDPOINT'&client_secret='$ARM_CLIENT_SECRET https://login.microsoftonline.com/$ARM_TENANT_ID/oauth2/token)
mgmt_access_token=$(jq .access_token -r <<< "$az_mgmt_resource_endpoint" )


echo "Databricks API: List Clusters"
clusterslist=$(curl -X GET -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" https://$workspaceUrl/api/2.0/clusters/list)
echo $clusterslist

echo "Databricks API: Create Clusters"
clusterscreate=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
'{
    "cluster_name": "dbz-sp-cluster2", 
    "spark_version": "10.4.x-scala2.12", 
    "node_type_id": "Standard_D3_v2",
    "spark_conf": {},
    "node_type_id": "Standard_DS3_v2",
    "autotermination_minutes": 120,
    "runtime_engine": "STANDARD",
    "autoscale": {
        "min_workers": 2,
        "max_workers": 8
    }
    }' https://$workspaceUrl/api/2.0/clusters/create )

echo $clusterscreate