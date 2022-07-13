echo "environment variable: $param_RBAC_Assignments"
echo "environment variable: $param_resourceGroupName"

for RBAC_Assignment in $param_RBAC_Assignments
do
    echo $RBAC_Assignment
    echo $RBAC_Assignment.User1
    echo $RBAC_Assignment.User1.role
    echo $RBAC_Assignment.User1.roleBeneficiaryObjID
done 



    #az role assignment create \
    #--role "$role" \
    #--assignee-object-id $roleBeneficiaryObjID \
    #--assignee-principal-type "ServicePrincipal" \
    #--scope $scopedTo
