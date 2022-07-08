targetScope = 'subscription'

// ################################################################################################################################################################//
//                                                                       Parameters                                                                                //
// ################################################################################################################################################################//
param location string
param environment string
param shouldCreateContainers bool
param keyVaultName string
param subscriptionID string
param containerNames array
param storageConfig object


// ################################################################################################################################################################//
//                                                                  DEPLOY RESOURCE GROUPS                                                                                //
// ################################################################################################################################################################//
resource azResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  dependsOn: []
  name: '${environment}-synapse-rg'
  // Location of the Resource Group Does Not Have To Match That of The Resouces Within. Metadate for all resources within groups can reside in 'uksouth' below
  location: location
}



// ################################################################################################################################################################//
//                                                                  KEY VAULT - SELECT KV                                                                                //
// ################################################################################################################################################################//

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName // Key Vault Name
  scope: resourceGroup(subscriptionID, azResourceGroup.name ) // SubID + Resource Group Name 
}






// ################################################################################################################################################################//
//                                                             DEPLOY SYNAPSE WS & Default SA
// Need to put in a condition that ignores this section if RBAC has already been deployed. Ensure you also add Client IP Address in Portal.                                                                             //
// ################################################################################################################################################################//
module synapsewsDeploy '../../../bicep/azResources/azSynapse/azSynapse.bicep' = {
  scope: resourceGroup('${environment}-synapse-rg')
  name: 'synapsewsdeploychd'
  dependsOn: [
    azResourceGroup
  ]
  params: {
    location: location
    environment: environment
    shouldCreateContainers: shouldCreateContainers
    adminPassword: kv.getSecret('sqlServerPassword')
    containerNames: containerNames
    storageConfig : storageConfig
  }
}

