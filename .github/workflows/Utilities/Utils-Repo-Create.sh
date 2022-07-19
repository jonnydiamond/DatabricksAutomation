az config set extension.use_dynamic_install=yes_without_prompt
dbx_workspace_name=$(az databricks workspace list -g $param_ResourceGroupName --query "[].name" -o tsv)
workspaceUrl=$(az databricks workspace list -g $param_ResourceGroupName --query "[].workspaceUrl" -o tsv)
workspace_id=$(az databricks workspace list -g $param_ResourceGroupName --query "[].id" -o tsv)

echo "Ingest JSON File"
json=$( jq '.' .github/workflows/Global_Parameters/$environment.json)
echo "${json}" | jq

echo "Configure All Clusters From Environment Parameters File"
for row in $(echo "${json}" | jq -r '.Git_Configuration[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }
    JSON_STRING=$( jq -n -c \
                --arg pat "$(_jq '.personal_access_token')" \
                --arg gu "$(_jq '.git_username')" \
                --arg gp "$(_jq '.git_provider')"  \
                '{personal_access_token: $pat,
                git_username: $gu,
                git_provider: $gp}' )
    
    git_credentials=$(curl -X POST -H "Authorization: Bearer $token" \
        -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
        -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
        -H 'Content-Type: application/json' \
        -d $JSON_STRING \
        https://$workspaceUrl/api/2.0/git-credentials )
done

for row in $(echo "${json}" | jq -r '.Repo_Configuration[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }
    JSON_STRING=$( jq -n -c \
                --arg url "$(_jq '.url')" \
                --arg pr "$(_jq '.provider')" \
                --arg pa "$(_jq '.path')"  \
                '{url: $url,
                provider: $pr,
                path: $pa}' )

    Repo_Configuration=$(curl -X POST -H "Authorization: Bearer $token" \
                -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
                -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
                -H 'Content-Type: application/json' \
                -d $JSON_STRING \
                https://$workspaceUrl/api/2.0/repos )
done




































#git_credentials=$(curl -X POST -H "Authorization: Bearer $token" \
#        -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
#        -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
#        -H 'Content-Type: application/json' \
#        -d $JSON_STRING
#        '{
#        "personal_access_token": "yhdjjk6kcmmv6zcfowmsh6pmcre3jbstwbk5sarxcwtutmlyu5ha", 
#        "git_username": "ciaranh@microsoft.com", 
#        "git_provider": "azureDevOpsServices"
#        }' https://$workspaceUrl/api/2.0/git-credentials )




#git_credentials=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
#'{
#"personal_access_token": "yhdjjk6kcmmv6zcfowmsh6pmcre3jbstwbk5sarxcwtutmlyu5ha", 
#"git_username": "ciaranh@microsoft.com", 
#"git_provider": "azureDevOpsServices"
#}' https://$workspaceUrl/api/2.0/git-credentials )

#echo $git_credentials 

## The Section CREATES The Repos --> 3 Folders 'Production, Staging and Test' in the DBX Repo for the SP. This will be locked Down 
## When changes are merged into each branch, an automated pipeline run will update the repo.
## This will ensure that the branch for the testing /production repo is up to date when we run jobs on it.


#create_repo_response=$(curl -X POST -H "Authorization: Bearer $token" \
#                -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" \
#                -H "X-Databricks-Azure-Workspace-Resource-Id: $workspace_id" \
#                -H 'Content-Type: application/json' -d \
#'{
#"url": "https://dev.azure.com/ciaranh0658/_git/devopsTemplates", 
#"provider": "azureDevOpsServices",
#"path": "/Repos/ce79c2ef-170d-4f1c-a706-7814efb94898/Development"
#}' https://$workspaceUrl/api/2.0/repos )

#echo $create_repo_response

#create_repo_response=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
#'{
#"url": "https://dev.azure.com/ciaranh0658/_git/devopsTemplates", 
#"provider": "azureDevOpsServices",
#"path": "/Repos/ce79c2ef-170d-4f1c-a706-7814efb94898/Production"
#}' https://$workspaceUrl/api/2.0/repos )

#echo $create_repo_response

#create_repo_response=$(curl -X POST -H "Authorization: Bearer $token" -H "X-Databricks-Azure-SP-Management-Token: $mgmt_access_token" -H "X-Databricks-Azure-Workspace-Resource-Id: $wsId" -H 'Content-Type: application/json' -d \
#'{
#"url": "https://dev.azure.com/ciaranh0658/_git/devopsTemplates", 
#"provider": "azureDevOpsServices",
#"path": "/Repos/ce79c2ef-170d-4f1c-a706-7814efb94898/Staging"
#}' https://$workspaceUrl/api/2.0/repos )

#echo $create_repo_response
