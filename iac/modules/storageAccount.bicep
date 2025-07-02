@description('Name of the storage account')
@minLength(2)
@maxLength(10)
param storageAccountName string 
@description('Location for the storage account')  
param location string = resourceGroup().location
@description('SKU name for the storage account')  
param skuName string = 'Standard_LRS' // Options: 'Standard_LRS', 'Standard_GRS', 'Standard_RAGRS', 'Premium_LRS'
@description('Access tier for the storage account') 
param accessTier string = 'Hot' // Options: 'Hot', 'Cool', 'Archive'
@description('Indicates if Hierarchical Namespace (HNS) is enabled for the storage account')  
param isHnsEnabled bool = false // Set to true for Data Lake Storage Gen2 capabilities
@description('Tags for the storage account')  
param tags object = {} // Tags for the storage account, e.g., { "environment": "production", "owner": "team" }
// Define a Storage Account resource in Azure using Bicep   
// This module allows you to create a Storage Account with specified parameters

param appName string  // Base name for the application resources
param stage string // Default stage for the application, can be overridden


var name = toLower('st${appName}${storageAccountName}${stage}') // Construct the storage account name based on appName and stage

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
//output storageAccountPrimaryConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}' // Primary connection string for the storage account
