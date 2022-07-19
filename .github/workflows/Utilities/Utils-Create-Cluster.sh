az config set extension.use_dynamic_install=yes_without_prompt
workspaceUrl=$(az databricks workspace list -g $param_ResourceGroupName --query "[].workspaceUrl" -o tsv)
workspace_id=$(az databricks workspace list -g $param_ResourceGroupName --query "[].id" -o tsv)

# List All Clusters Which Exist
listClusters=$(curl -X GET -H "Authorization: Bearer $token" \
                    -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
                    -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
                    -H 'Content-Type: application/json' \
                    https://$workspaceUrl/api/2.0/clusters/list )

# Extract Existing Cluster Names
cluster_names=$( jq -r '[.clusters[].cluster_name]' <<< "$listClusters")

echo "Ingest JSON Environment File"
json=$( jq '.' .github/workflows/Global_Parameters/$environment.json)
echo "${json}" | jq

echo "Configure All Clusters From Environment Parameters File"
for row in $(echo "${json}" | jq -r '.Clusters[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }
    if [[ ! " ${cluster_names[*]} " =~ "$(_jq '.cluster_name')" ]]; then

        echo "Cluster Does Not Exist: Create Cluster... "
        
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
        
        clusterscreate=$(curl -X POST -H "Authorization: Bearer $token" \
        -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
        -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
        -H 'Content-Type: application/json' \
        -d $JSON_STRING \
        https://$workspaceUrl/api/2.0/clusters/create )

    else
        echo "Cluster Exists... Ignore"  
    fi
done

