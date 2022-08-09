// ################################################################################################################################################################//
//                                                                       Define Parameters                                                                  
// ################################################################################################################################################################//

param location string
param workspaceName string

@allowed([
  'standard'
  'premium'
])
param pricingTier string = 'premium'
param repoConfig object
param environment string


// ################################################################################################################################################################//
//                                                                       Define Variables                                                                    
// ################################################################################################################################################################//
//var roleDefinitionAzureStorageBlobContributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
//var roleDefinitionOwner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
var roleDefinitionAzureEventHubsDataOwner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
var roleDefinitionUser = guid('${resourceGroup().id}/8e3af657-a8ff-443c-a75c-2fe8c4bcb635/')

var managedResourceGroupName = '${workspaceName}-mrg-databricks'


// ################################################################################################################################################################//
//                                                             Deploy AzDatabricks Workspace                                                                     
// ################################################################################################################################################################//
resource azDatabricksWS 'Microsoft.Databricks/workspaces@2021-04-01-preview' = {
  name: workspaceName
  
  location: location
  properties: {
    managedResourceGroupId: '${subscription().id}/resourceGroups/${managedResourceGroupName}'
    publicNetworkAccess: 'Enabled'
    authorizations: [
       {
         principalId: '0e3c30b0-dd4e-4937-96ca-3fe88bd8f259'
         roleDefinitionId: roleDefinitionUser 
       }
    ]
  }
  sku: {
    name: pricingTier
  }
  

}

//resource spRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
//  name: guid(azDatabricksWS.id, roleDefinitionAzureEventHubsDataOwner)
//  dependsOn: [
//    azDatabricksWS
//  ]
//  properties: {
//    principalId: 'ab926dd1-657d-4bb2-9987-c7857046d0dd'
//    roleDefinitionId: roleDefinitionUser
//    principalType: 'ServicePrincipal'
//  }
//}


output azDatabricksWorkspaceID string = azDatabricksWS.id



