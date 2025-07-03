@minLength(2)
@maxLength(10)
param storageAccountName string 
param location string = resourceGroup().location
param skuName string = 'Standard_LRS' // Options: 'Standard_LRS', 'Standard_GRS', 'Standard_RAGRS', 'Premium_LRS'
param tags object = {} 
param appName string 
param stage string 


var name = toLower('st${appName}${storageAccountName}${stage}') 

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  tags: tags
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name  
