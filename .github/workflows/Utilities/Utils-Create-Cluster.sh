echo "Databricks API: List Clusters"
clusterslist=$(curl -X GET -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" https://$workspaceUrl/api/2.0/clusters/list)
echo $clusterslist

#---------------------------------------------------
echo $environment

echo "Ingest JSON File"
json=$( jq '.' .github/workflows/Global_Parameters/$environment.json)
echo "${json}" | jq

echo "Configure All Clusters From Environment Parameters File"

for row in $(echo "${json}" | jq -r '.Clusters[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }

    echo "Databricks API: Create Clusters"
    clusterscreate=$(curl -X POST -H "Authorization: Bearer $token" \
    -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
    -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" \
    -H 'Content-Type: application/json' -d \
    '{
        "cluster_name": "$(_jq '.cluster_name')", 
        "spark_version": "$(_jq '.spark_version')" , 
        "node_type_id": "$(_jq '.node_type_id')" ,
        "spark_conf": "$(_jq '.spark_conf')" ,
        "autotermination_minutes": "$(_jq '.autotermination_minutes')" ,
        "runtime_engine": "$(_jq '.runtime_engine')" ,
        "autoscale": "$(_jq '.autoscale')" 
    }' https://$workspaceUrl/api/2.0/clusters/create )
    

    echo "$(_jq '.cluster_name')"
    echo "$(_jq '.spark_version')"
    echo "$(_jq '.node_type_id')" 
    echo "$(_jq '.spark_conf')"
    echo "$(_jq '.autotermination_minutes')"
    echo "$(_jq '.runtime_engine')"
    echo "$(_jq '.autoscale')"

    echo "ClusterCreateOutput"
    echo clusterscreate
done


















#echo "Databricks API: Create Clusters"
#clusterscreate=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
#'{
#    "cluster_name": "dbz-sp-cluster2", 
#    "spark_version": "10.4.x-scala2.12", 
#    "node_type_id": "Standard_D3_v2",
#    "spark_conf": {},
#    "autotermination_minutes": 120,
#    "runtime_engine": "STANDARD",
#    "autoscale": {
#        "min_workers": 2,
#        "max_workers": 8
#    }
#    }' https://$workspaceUrl/api/2.0/clusters/create )
#echo $clusterscreate