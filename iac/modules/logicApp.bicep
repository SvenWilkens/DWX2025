param location string = resourceGroup().location
param logicAppName string 

param appName string  
param stage string
param workflow_app_storage_account_name string 
param serverFarmId string 
param appSettings array = [] 
param tags object = {}  
param emailSender string
param emailDomain string
param emailConnectionRuntimeUrl string
param appInsightsConnectionString string 

param identityType string = 'SystemAssigned'

resource wf_storage_acount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: workflow_app_storage_account_name
}



var name = toLower('la-${appName}-${logicAppName}-${stage}')

var defaultAppSettings = [
  {
    name: 'APP_KIND'
    value: 'workflowApp'
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'dotnet'
  }
  {
    name: 'WEBSITE_NODE_DEFAULT_VERSION'
    value: '~20'
  }
    {
    name: 'AzureFunctionsJobHost__extensionBundle__id'
    value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
  }
  {
    name: 'AzureFunctionsJobHost__extensionBundle__version'
    value: '[1.*, 2.0.0)'
  }
  {
    name: 'FUNCTIONS_INPROC_NET8_ENABLED'
    value: 1
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: 'DefaultEndpointsProtocol=https;AccountName=${workflow_app_storage_account_name};AccountKey=${wf_storage_acount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
  }
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${workflow_app_storage_account_name};AccountKey=${wf_storage_acount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
  }
  {
    name: 'WEBSITE_CONTENTSHARE'
    value: toLower(workflow_app_storage_account_name)
  }
  {
    name: 'Z_COMMUNICATIONSERVICE_CONNECTIONNAME'
    value: '${appName}-${stage}-communicationserviceconnection'
  }
  {
    name: 'Z_COMMUNICATIONSERVICE_CONNECTIONRUNTIMEURL'
    value: emailConnectionRuntimeUrl
  }
  {
    name: 'Z_COMMUNICATIONSERVICE_SENDER'
    value: '${emailSender}@${emailDomain}'
  }
 {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsightsConnectionString
  }

]


resource logicAppResource 'Microsoft.Web/sites@2024-11-01' = {
  name: name
  location: location
  kind: 'functionapp,workflowapp'
  properties: {
    httpsOnly: true
    serverFarmId:serverFarmId
    siteConfig: {
      appSettings: concat(defaultAppSettings, appSettings)
    }
  }
  identity: {
    type: identityType
  }
  tags: tags
}


output logicAppId string = logicAppResource.id
output logicAppName string = logicAppResource.name  
output logicAppPrincipalId string = logicAppResource.identity.principalId
