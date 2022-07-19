#echo "Databricks API: List Clusters"
#clusterslist=$(curl -X GET -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" https://$workspaceUrl/api/2.0/clusters/list)
#echo $clusterslist
#---------------------------------------------------
echo $environment

az config set extension.use_dynamic_install=yes_without_prompt
dbx_workspace_name=$(az databricks workspace list -g $param_ResourceGroupName --query "[].name" -o tsv)
workspaceUrl=$(az databricks workspace list -g $param_ResourceGroupName --query "[].workspaceUrl" -o tsv)
workspace_id=$(az databricks workspace list -g $param_ResourceGroupName --query "[].id" -o tsv)

echo "Ingest JSON File"
json=$( jq '.' .github/workflows/Global_Parameters/$environment.json)
echo "${json}" | jq

echo "Configure All Clusters From Environment Parameters File"
for row in $(echo "${json}" | jq -r '.Clusters[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }

    listClusters=$(curl -X GET -H "Authorization: Bearer $token" \
                    -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
                    -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
                    -H 'Content-Type: application/json' \
                    https://$workspaceUrl/api/2.0/clusters/list )

    echo "List Clusters"
    echo $listClusters

    cluster_names=$( jq -r '[.clusters[].cluster_name]' <<< "$listClusters")
    echo "Cluster Name"
    echo $cluster_names


    if [[ " ${cluster_names[*]} " =~ "dbz-sp-cluster2" ]]; then
        echo "present"
    fi

    if [[ ! " ${cluster_names[*]} " =~ "dbz-sp-cluster2" ]]; then
        echo "not present"
    fi

    for name in $cluster_names
    do
    echo $name
    done

    exit 1


    


    JSON_STRING=$( jq -n -c \
                --arg cn "$(_jq '.cluster_name')" \
                --arg sv "$(_jq '.spark_version')" \
                --arg nt "$(_jq '.node_type_id')"  \
                --arg nw "$(_jq '.autoscale.max_workers')" \
                --arg sc "$(_jq '.spark_conf')" \
                --arg at "$(_jq '.autotermination_minutes')" \
                '{cluster_name: $cn,
                spark_version: $sv,
                node_type_id: $nt,
                num_workers: ($nw|tonumber),
                autotermination_minutes: ($at|tonumber),
                spark_conf: ($sc|fromjson)}' )

    echo "Databricks API: Create Clusters"
    clusterscreate=$(curl -X POST -H "Authorization: Bearer $token" \
    -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
    -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
    -H 'Content-Type: application/json' \
    -d $JSON_STRING \
    https://$workspaceUrl/api/2.0/clusters/create )

    echo "ClusterCreateOutput"
    echo clusterscreate
done
