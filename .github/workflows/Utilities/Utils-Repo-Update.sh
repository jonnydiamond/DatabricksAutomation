az config set extension.use_dynamic_install=yes_without_prompt
dbx_workspace_name=$(az databricks workspace list -g $param_ResourceGroupName --query "[].name" -o tsv)
workspaceUrl=$(az databricks workspace list -g $param_ResourceGroupName --query "[].workspaceUrl" -o tsv)
workspace_id=$(az databricks workspace list -g $param_ResourceGroupName --query "[].id" -o tsv)

# I have left the "Path" out as it doesn't seem to work. I think it might be permissions issue. States 'Resource is not found'. I wonder if this is because Devops PAT token was used for git configuring the service principal.
## The section below updates the repos. We will have it triggered when when the respective branch is updated (successfully merge request)

reposWithManagePermissions=$(curl -X GET -H "Authorization: Bearer $token" \
                            -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
                            -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
                            -H 'Content-Type: application/json' \
                            https://$workspaceUrl/api/2.0/repos )
echo $reposWithManagePermissions


#developRepoIDStaging=$( jq -r '.repos[] | select( .path | contains("Staging")) | .id' <<< "$reposWithManagePermissions")
developRepoIDStaging=$( jq -r '.repos[] | select( .path | contains("Development")) | .id' <<< "$reposWithManagePermissions")
#prodRepoIDStaging=$( jq -r '.repos[] | select( .path | contains("Production")) | .id' <<< "$reposWithManagePermissions")
echo "Repo Staging ID"
echo $testRepoIDStaging


# .changes[] | select( .changeType | contains("No")) | .delta

#echo $developRepoIDStaging
#echo $testRepoIDStaging
#echo $prodRepoIDStaging

# If there is a change to the develop branch, we will update Files in the Staging/Test Folder
update_repo_response=$(curl -X PATCH \
        -H "Authorization: Bearer $token" \
        -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
        -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
        -H 'Content-Type: application/json' -d \
'{
"branch": "develop"
}' https://$workspaceUrl/api/2.0/repos/$developRepoIDStaging )

echo $update_repo_response

# If there is a change to the master branch, we will update files in the Production Folder
#update_repo_response=$(curl -X PATCH -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
#'{
#"branch": "master"
#}' https://$workspaceUrl/api/2.0/repos/$prodRepoIDStaging )

#echo $update_repo_response

exit 1
