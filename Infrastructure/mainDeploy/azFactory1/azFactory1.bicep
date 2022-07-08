targetScope = 'subscription'

param location string
param environment string
param repoConfig object
param storageConfig object
param containerNames array



// ################################################################################################################################################################//
//                                                                       Create Resource Group                                                                    
// ################################################################################################################################################################//
resource azResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  dependsOn: []
  name: '${environment}-bicep-rg'
  // Location of the Resource Group Does Not Have To Match That of The Resouces Within. Metadate for all resources within groups can reside in 'uksouth' below
  location: location
}


// ################################################################################################################################################################//
//                                                                       Module for Deploying Factory and Storage
// Outcome:
// dev Resource Group  --> Contains DataFactory + Storage Account
// test Resource Group --> Contains DataFactory + Storage Account
// prod Resource Group --> Contains DataFactory + Storage Account
//                                                           
// ################################################################################################################################################################//
module azFactoryAndStorage '../../../bicep/azResources/azFactory/azFactory.bicep' =  {
  dependsOn: [
    azResourceGroup
  ]
  scope: resourceGroup('${environment}-bicep-rg')
  name: 'azFactoryAndStorage' 
  params: {
    environment: environment
    location: location
    repoConfig: repoConfig
    storageConfig: storageConfig
    containerNames: containerNames
  }
}


