#!/usr/bin/env bash


#test=$( jq --compact-output '.RBAC_Assignments[0].role' .github/workflows/Global_Parameters/Development.json)
#echo $test
#echo "${#test[@]}"


readarray -t arr < < $( jq -r '.RBAC_Assignments[]' .github/workflows/Global_Parameters/Development.json)
echo "roles json scrape"
echo $readarray

#echo "json - cat"
#json=$(
#    cat <<- EOF
#    $roles
#EOF
#)


read -a array <<< $roles

echo "read - array"
echo $roles


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
