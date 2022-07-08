// ################################################################################################################################################################//
//                                                                       Define Parameters                                                                  
// ################################################################################################################################################################//
param location string
param environment string
param repoConfig object
param storageConfig object
param containerNames array


// ################################################################################################################################################################//
//                                                                       Define Variables                                                                    
// ################################################################################################################################################################//
// var StorageAccountKey = Storage_Account_Deployment.outputs.storagekey
var storageaccountname = azStorage.outputs.storageaccountname
var roleDefinitionAzureEventHubsDataOwner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')


// ################################################################################################################################################################//
//                                                             Deploy Storage Account Per Environment                                                                         
// ################################################################################################################################################################//

module azStorage '../azDataLake/azDataLake.bicep' =  {
  dependsOn: []
  scope: resourceGroup('${environment}-bicep-rg')
  name: 'Storage_Account_Deployment'
  params: {
    location: 'uksouth'
    environment: environment
    storageConfig: storageConfig
    containerNames: containerNames
  }
}


// ################################################################################################################################################################//
//                                                               Deploy Data Factory Per Environment                                                                       
// ################################################################################################################################################################//
resource azFactory 'Microsoft.DataFactory/factories@2018-06-01' =  {
  dependsOn: [
    azStorage
  ]
  name: 'adf${environment}chd'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    repoConfiguration: repoConfig
    publicNetworkAccess: 'Enabled'
  }
  }


// ################################################################################################################################################################//
//                                                      Deploy Data Factory Linked Service Per Environment                                                              
// ################################################################################################################################################################//
resource azFactoryLinked 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: azFactory
  name: 'adflinkedservice${environment}${location}'
  properties: {
    type: 'AzureBlobFS'
    typeProperties: {
      url: 'https://${storageaccountname}.dfs.core.windows.net'
    }
  }
}


// ################################################################################################################################################################//
//                                                 Assign Blob Contributor RBAC To Data Factory Per Environment                                                                             
// ################################################################################################################################################################//
resource rbacDataCont 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  dependsOn: [
    azStorage
    azFactoryLinked
  ]

  name: guid(azFactory.id, roleDefinitionAzureEventHubsDataOwner)
  // As Scope is not defined, the role will sccope to the file. As it is not specified it defaults to Resource Group.
  properties: {
    principalId: azFactory.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinitionAzureEventHubsDataOwner
  }
}
