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


for row in $(echo "${json}" | jq -r '.RBAC_Assignments[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }
    ROLES_ARRAY="$(_jq '.roles')"
    echo $ROLES_ARRAY

    # Before: [ "Contributor", "DBX_Custom_Role", "Key Vault Administrator" ]
    # xargs trims whitespace on either side. -n removes newline characters
    ROLES_ARRAY_PARSED=$( echo $ROLES_ARRAY | jq -r | tr -d "[]" | tr -d \'\" | xargs echo -n )
    # After: Contributor, DBX_Custom_Role, Key Vault Administrator
    echo $ROLES_ARRAY_PARSED
    Field_Separator=$IFS
    IFS=,
    for ROLE in $ROLES_ARRAY_PARSED; do
        ROLE=$( echo $ROLE | xargs )
        
        echo "Role: $ROLE"
        echo "ObjectID $(_jq '.roleBeneficiaryObjID')"
        echo "Scope: $RESOURCE_GROUP_ID"
        echo "Principal Type $(_jq '.principalType')"

        az role assignment create \
        --role "$ROLE" \
        --assignee-object-id $(_jq '.roleBeneficiaryObjID') \
        --assignee-principal-type "$(_jq '.principalType')" \
        --scope "$RESOURCE_GROUP_ID"
        #--scope "$(_jq '.scope')"

    done    
    IFS=$Field_Separator
done













#echo "Iterate And Assign RBAC Permissions"
#for row in $(echo "${json}" | jq -r '.RBAC_Assignments[] | @base64'); do
#    _jq() {
#        echo ${row} | base64 --decode | jq -r ${1}
#    }
    # [ "Contributor", "DBX_Custom_Role", "Key Vault Administrator" ]
#    role_array=$(_jq '.roles')
#    echo $role_array

#    echo "test"
#    echo "$(_jq '.roles')" | jq -r ' @sh '



    #roleBeneficiaryObjID=$(_jq '.roleBeneficiaryObjID')
    #principalType="$(_jq '.principalType')"
    #echo $roleBeneficiaryObjID
    #echo $principalType

    #for new in ${role_array[@]}; do echo $new done
        #echo $roleBeneficiaryObjID
        #echo $principalType
    #az role assignment create \
    #--role "$(_jq '.role')" \
    #--assignee-object-id $(_jq '.roleBeneficiaryObjID') \
    #--assignee-principal-type "$(_jq '.principalType')" \
    #--scope "$RESOURCE_GROUP_ID"
    #--scope "$(_jq '.scope')"
#done


