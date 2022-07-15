#!/usr/bin/env bash

# Ensure That Your DevOps/PipelineAgent Has Owner RBAC Assigned. Do This Manually In Azure Portal 

echo "Ingest and Format JSON File"
json=$( jq '.' .github/workflows/Global_Parameters/Development.json)

echo "Iterate And Assign RBAC Permissions"
for row in $(echo "${json}" | jq -r '.RBAC_Assignments[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }
    
    az role assignment create \
    --role "$(_jq '.role')" \
    --assignee-object-id $(_jq '.roleBeneficiaryObjID') \
    --assignee-principal-type "ServicePrincipal" \
    --scope "$(_jq '.scope')"

