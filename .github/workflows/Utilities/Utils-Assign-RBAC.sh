#!/usr/bin/env bash

# Ensure That Your DevOps/PipelineAgent Has Owner RBAC Assigned. Do This Manually In Azure Portal 


#test=$( jq --compact-output '.RBAC_Assignments[0].role' .github/workflows/Global_Parameters/Development.json)
#echo $test
#echo "${#test[@]}"

sample='[{"name":"foo"},{"name":"bar"}]'
echo "${sample}" | jq 
echo "${sample}" | jq -r '.[] | @base64'

for row in $(echo "${sample}" | jq -r '.[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }
    echo $(_jq '.name')
done


roles=$( jq '.' .github/workflows/Global_Parameters/Development.json)
echo "${roles}" | jq 
echo "${roles}" | jq -r '.RBAC_Assignments[] | @base64'

for row in $(echo "${roles}" | jq -r '.RBAC_Assignments[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }
    echo $(_jq '.role')
    echo $(_jq '.roleBeneficiaryObjID')
    echo $(_jq '.scope')
    echo "Next Iteration"

    az role assignment create \
    --role "$(_jq '.role')" \
    --assignee-object-id $(_jq '.roleBeneficiaryObjID') \
    --assignee-principal-type "ServicePrincipal" \
    --scope "$(_jq '.scope')"

done

    #az role assignment create \
    #--role "$role" \
    #--assignee-object-id $roleBeneficiaryObjID \
    #--assignee-principal-type "ServicePrincipal" \
    #--scope $scopedTo
