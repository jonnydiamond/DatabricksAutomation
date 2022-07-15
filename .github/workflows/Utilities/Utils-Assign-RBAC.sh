#!/usr/bin/env bash


test=$( jq --compact-output '.RBAC_Assignments[0].role' .github/workflows/Global_Parameters/Development.json)
echo $test
echo "${#test[@]}"


roles=$( jq --compact-output '[.RBAC_Assignments[].role]' .github/workflows/Global_Parameters/Development.json)
echo $roles
echo "${#roles[@]}"


#for RBAC_Assignment in $test
#do
#    test=$( jq --compact-output '.RBAC_Assignments[0].role' .github/workflows/Global_Parameters/Development.json)
#    echo "$RBAC_Assignment"
#    echo $i
#    ((i=i+1))
#done 



    #az role assignment create \
    #--role "$role" \
    #--assignee-object-id $roleBeneficiaryObjID \
    #--assignee-principal-type "ServicePrincipal" \
    #--scope $scopedTo
