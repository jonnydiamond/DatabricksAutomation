#!/usr/bin/env bash

sudo apt-get install jq

COUNTER=0
echo $COUNTER



test=$( jq '.RBAC_Assignments[]' .github/workflows/Global_Parameters/Development.json)
developRepoIDStaging=$( jq -r '.RBAC_Assignments[].role' <<< "$test")

echo $test


for RBAC_Assignment in $test
do
    echo "$RBAC_Assignment"
done 



    #az role assignment create \
    #--role "$role" \
    #--assignee-object-id $roleBeneficiaryObjID \
    #--assignee-principal-type "ServicePrincipal" \
    #--scope $scopedTo
