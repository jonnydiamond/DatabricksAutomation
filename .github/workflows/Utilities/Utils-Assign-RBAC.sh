#!/usr/bin/env bash

COUNTER=0
echo $COUNTER


test=$( jq '[.RBAC_Assignments[].role]' .github/workflows/Global_Parameters/Development.json)
echo $test


for RBAC_Assignment in $test
do
    echo $RBAC_Assignment
done 



    #az role assignment create \
    #--role "$role" \
    #--assignee-object-id $roleBeneficiaryObjID \
    #--assignee-principal-type "ServicePrincipal" \
    #--scope $scopedTo
