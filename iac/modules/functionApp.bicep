param functionAppName string

param appName string 
param stage string 
param appSettings array = [] 
param location string = resourceGroup().location  
param appServicePlanId string
param storageAccountName string
param tags object = {}  
param identityType string = 'SystemAssigned' 
param appInsightsConnectionString string 

var name = toLower('fa-${appName}-${functionAppName}-${stage}')

resource wf_storage_acount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

var defaultAppSettings = [
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'DOTNET-ISOLATED'
  }
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${wf_storage_acount.listKeys().keys[0].value}'
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${wf_storage_acount.listKeys().keys[0].value}'
  }
  {
    name: 'WEBSITE_CONTENTSHARE'
    value: toLower(functionAppName)
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsightsConnectionString
  }
  {
    name: 'WEBSITE_RUN_FROM_PACKAGE'
    value: '0'
  }
  {
    name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
    value: '1'
  }

]

resource functionApp 'Microsoft.Web/sites@2024-11-01' = {
  name: name
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      appSettings: concat(defaultAppSettings, appSettings)
    }
  }
  identity: {
    type: identityType
  
  }
  tags: tags
}

output functionAppId string = functionApp.id 
output functionAppName string = functionApp.name 
output functionAppPrincipalId string = functionApp.identity.principalId 
