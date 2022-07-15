#!/usr/bin/env bash


#test=$( jq --compact-output '.RBAC_Assignments[0].role' .github/workflows/Global_Parameters/Development.json)
#echo $test
#echo "${#test[@]}"

sample='[{"name":"foo"},{"name":"bar"}]'
echo "${sample}" | jq 
echo "${sample}" | jq -r '.[]'

#roles=$( jq '.RBAC_Assignments[].role' .github/workflows/Global_Parameters/Development.json)
#echo "roles json scrape"
#echo $roles

echo "${roles}" | jq 
echo "${roles}" | jq -r '.RBAC_Assignments[].role'

#roles=$( jq '.RBAC_Assignments[]' .github/workflows/Global_Parameters/Development.json)
#echo "roles json scrape"
#echo $roles

#echo "json - cat"
#json=$(
#    cat <<- EOF
#    $roles
#EOF
#)


#read -a array <<< $roles

#echo "read - array"
#echo $roles


#echo $roles
#array=($roles)
#echo $array
#echo "${#array[@]}"


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
