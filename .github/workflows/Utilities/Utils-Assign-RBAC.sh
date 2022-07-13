#!/usr/bin/env bash

COUNTER="0"
echo $COUNTER


echo "$param_RBAC_Assignments_"$COUNTER"_role"

echo "${param_RBAC_Assignments_"$COUNTER"_role}"

echo ${"param_RBAC_Assignments_"$COUNTER"_role"}

echo "param_RBAC_Assignments_"$COUNTER"_role"


test=$("param_RBAC_Assignments_"$COUNTER"_role")
echo $test
which $test

which "param_RBAC_Assignments_"$COUNTER"_role"

echo "${param_RBAC_Assignments_"$COUNTER"_role}"

echo "environment variable: $param_resourceGroupName"

#while [ -z "${param_RBAC_Assignments_$COUNTER_role}"]
#do  
#    echo "$COUNTER"
#    COUNTER=$[COUNTER + 1]
#    echo $COUNTER
#done 




#for RBAC_Assignment in $param_RBAC_Assignments
#do
#    echo $RBAC_Assignment
#    echo $RBAC_Assignment.User1
#    echo $RBAC_Assignment.User1.role
#    echo $RBAC_Assignment.User1.roleBeneficiaryObjID
#done 



    #az role assignment create \
    #--role "$role" \
    #--assignee-object-id $roleBeneficiaryObjID \
    #--assignee-principal-type "ServicePrincipal" \
    #--scope $scopedTo
