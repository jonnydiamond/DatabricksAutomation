#!/usr/bin/env bash

i=1
echo $i


test=$( jq -r '[.RBAC_Assignments[].role]' .github/workflows/Global_Parameters/Development.json)
echo $test

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for RBAC_Assignment in $test
do
    echo "$RBAC_Assignment"
    echo $i
    ((i=i+1))
done 



    #az role assignment create \
    #--role "$role" \
    #--assignee-object-id $roleBeneficiaryObjID \
    #--assignee-principal-type "ServicePrincipal" \
    #--scope $scopedTo
