#!/usr/bin/env bash

# Ensure That Your DevOps/PipelineAgent Has Owner RBAC Assigned. Do This Manually In Azure Portal 
# Anything With param_ Was Set As An Environment Variable Using "antifree/json-to-variables@v1.0.1" In Main Yaml Pipeline
echo "SubscriptionID: $param_SubscriptionId"
echo "Resource Group Name: $param_parameters_resourceGroupName_value"

RESOURCE_GROUP_ID=$( az group show -n $param_parameters_resourceGroupName_value --query id -o tsv )
echo "Resource Group Resource ID: $RESOURCE_GROUP_ID"

echo "Ingest JSON File"
json=$( jq '.' .github/workflows/Pipeline_Param/$environment.json)
echo "${json}" | jq

echo "Iterate And Assign RBAC Permissions"
for row in $(echo "${json}" | jq -r '.RBAC_Assignments[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }
    az role assignment create \
    --role "$(_jq '.role')" \
    --assignee-object-id $(_jq '.roleBeneficiaryObjID') \
    --assignee-principal-type "$(_jq '.principalType')" \
    --scope "$RESOURCE_GROUP_ID"
    #--scope "$(_jq '.scope')"
done


