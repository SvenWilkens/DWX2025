targetScope = 'subscription'
param stage string = 'dev' 
param appName string = 'dwxdemo5' 
param location string = 'West Europe' 
param apimKey string = '754cd320c4224bab8fdbe0e9d777334e'

var tags = {
  environment: stage
  appName: appName
  owner: '  '
}
var name = toLower('rg-${appName}-${stage}')
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: name
  location: location
  tags: {
    environment: stage
    appName: appName
    owner: 'Sven-Wilkens@outlook.de'
  }
}


module appInsights 'modules/appInsights.bicep' = {
  name: 'appInsightsModule'
  scope: resourceGroup
  params: {
    appName: appName
    stage: stage
    location: resourceGroup.location
  }
}

var skuFa object = {
  name: 'Y1'
  tier: 'Dynamic'
 capacity: 1
}

module appServicePlanFunctionApp 'modules/appServicePlan.bicep' = {
  name: 'appServicePlanFunctionApp'
  scope: resourceGroup
  params: {
    appServicePlanName: 'fa'
    location: resourceGroup.location
    isLinux: false
    tags: tags
    appName:appName
    stage:stage
    sku: skuFa
  }
}
var skuLa object = {
  name: 'WS1'
  tier: 'WorkflowStandard'
  size: 'WS1'
}

module appServicePlanLogicApp 'modules/appServicePlan.bicep' = {
  name: 'appServicePlanLogicApp'
  scope: resourceGroup
  params: {
    appServicePlanName: 'la'
    location: resourceGroup.location
    isLinux: false
    tags: tags
    appName:appName
    stage:stage
    sku: skuLa
  }
}

module storageAccountFunctionApp 'modules/storageAccount.bicep' = {
  name: 'storageAccountModuleFunctionApp'
  scope: resourceGroup
  params: {
    storageAccountName: 'fa'
    location: resourceGroup.location
    tags: tags
    appName:appName
    stage:stage
  }
}

module storageAccountlogicApp 'modules/storageAccount.bicep' = {
  name: 'storageAccountModuleLogicApps'
  scope: resourceGroup
  params: {
    storageAccountName: 'la'
    location: resourceGroup.location
    tags: tags
    appName:appName
    stage:stage
  }
}

var functionAppSettings = [
 {
    name: 'serviceBusConnection'
    value: '${serviceBus.outputs.serviceBusNamespaceName}.servicebus.windows.net'
  }
   {
    name: 'QueueName'
    value: serviceBusQueueIn.outputs.serviceBusQueueName
  }
]
module functionApp 'modules/functionApp.bicep' ={
  scope: resourceGroup
  params: {
    appServicePlanId:  appServicePlanFunctionApp.outputs.appServicePlanId
    functionAppName: 'integration-receiver'
    storageAccountName: storageAccountFunctionApp.outputs.storageAccountName 
    appName:appName
    stage:stage
    tags: tags
    appInsightsConnectionString: appInsights.outputs.instrumentationKey
    appSettings: functionAppSettings
  }
}
   
var logicAppSettings = [
 {
    name: 'serviceBus_fullyQualifiedNamespace'
    value: '${serviceBus.outputs.serviceBusNamespaceName}.servicebus.windows.net'
  }
   {
    name: 'QueueName'
    value: serviceBusQueueIn.outputs.serviceBusQueueName
  }
   {
    name: 'ProcessQueueName'
    value: serviceBusQueueOut.outputs.serviceBusQueueName
  }
  {
    name: 'ApimKey'
    value: apimKey
  }
  {
    name: 'acsemail-api-id' 
    value: '/subscriptions/${ subscription().subscriptionId}/providers/Microsoft.Web/locations/westeurope/managedApis/acsemail'
  }
  {
    name: 'acsemail-connection-id'
    value: '/subscriptions/${ subscription().subscriptionId}/resourceGroups/${resourceGroup.name}/providers/Microsoft.Web/connections/${emailCommunication.outputs.name}'
  }
  {
    name: 'acsemail-ConnectionRuntimeUrl'
    value: emailCommunication.outputs.connectionRuntimeUrl
  }
]

module logicApp 'modules/logicApp.bicep' = {
  scope: resourceGroup
  params: {
    logicAppName: 'integration-processor'
    serverFarmId: appServicePlanLogicApp.outputs.appServicePlanId
    workflow_app_storage_account_name: storageAccountlogicApp.outputs.storageAccountName
    appName:appName
    stage:stage
    tags: tags
    emailConnectionRuntimeUrl: emailCommunication.outputs.connectionRuntimeUrl
    emailDomain: emailCommunication.outputs.domain
    emailSender:emailCommunication.outputs.user
    appInsightsConnectionString: appInsights.outputs.instrumentationKey
    appSettings: logicAppSettings
  }
}

module serviceBus 'modules/serviceBus.bicep' = {
  name: 'serviceBusModule'
  scope: resourceGroup
  params: {
    serviceBusName: 'integration'
    location: resourceGroup.location
    sku: {
      name: 'Standard'
      tier: 'Standard'
    }
    identityType: 'SystemAssigned'
    appName:appName
    stage:stage
    tags: tags
  }
}

module serviceBusQueueIn 'modules/serviceBusQueue.bicep' = {
  scope: resourceGroup
  name: 'serviceBusQueueModuleIn001'
  params: {
    appName: appName
    serviceBusName: serviceBus.outputs.serviceBusNamespaceName
    queueName: 'receive-order'
  }
}

module serviceBusQueueOut 'modules/serviceBusQueue.bicep' = {
  scope: resourceGroup
  name: 'serviceBusQueueModuleout'
  params: {
    appName: appName
    serviceBusName: serviceBus.outputs.serviceBusNamespaceName
    queueName: 'process-order'
  }
}

var serviceBusReceiver = '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
var serviceBusSender = '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'

module roleAssignmentModuleIn001 'modules/serviceBusQueue-roleassignment.bicep' = {
  name: 'addAzureServiceBusDataReceiverRoleModule'
  scope: resourceGroup
  params: {
    funcAppPrincipalId: logicApp.outputs.logicAppPrincipalId
    serviceBusName: serviceBus.outputs.serviceBusNamespaceName
    serviceBusQueueName: serviceBusQueueIn.outputs.serviceBusQueueName
    role: serviceBusReceiver
  }
}

module roleAssignmentModuleIn002 'modules/serviceBusQueue-roleassignment.bicep' = {
  name: 'addAzureServiceBusDataReceiverRoleModule2'
  scope: resourceGroup
  params: {
    funcAppPrincipalId: functionApp.outputs.functionAppPrincipalId
    serviceBusName: serviceBus.outputs.serviceBusNamespaceName
    serviceBusQueueName: serviceBusQueueIn.outputs.serviceBusQueueName
    role: serviceBusSender
  }
}

module roleAssignmentModuleOut001 'modules/serviceBusQueue-roleassignment.bicep' = {
  name: 'addAzureServiceBusDataSenderOut001'
  scope: resourceGroup
  params: {
    funcAppPrincipalId: logicApp.outputs.logicAppPrincipalId
    serviceBusName: serviceBus.outputs.serviceBusNamespaceName
    serviceBusQueueName: serviceBusQueueOut.outputs.serviceBusQueueName
    role: serviceBusSender
  }
}

module roleAssignmentModuleFa 'modules/serviceBus-roleassignment.bicep' = {
  name: 'roleAssignmentModuleFa'
  scope: resourceGroup
  params: {
    funcAppPrincipalId: functionApp.outputs.functionAppPrincipalId
    serviceBusName: serviceBus.outputs.serviceBusNamespaceName
    role: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  }
}

module roleAssignmentModuleLa 'modules/serviceBus-roleassignment.bicep' = {
  name: 'roleAssignmentModuleLa'
  scope: resourceGroup
  params: {
    funcAppPrincipalId: logicApp.outputs.logicAppPrincipalId
    role: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
     serviceBusName: serviceBus.outputs.serviceBusNamespaceName
  }
}

module emailCommunication 'modules/EmailCommunication.bicep' = {
  name: 'EmailCommunicationModule'
  scope: resourceGroup
  params: {
    appName: appName
    stage: stage
    location: resourceGroup.location
  }
}

module communicationServiceConnectionAccessPolicyModule 'modules/communicationServiceConnectionAccessPolicy.bicep' = {
  name: 'communicationServiceConnectionAccessPolicyModule'
  scope: resourceGroup
  params: {
    appName: appName
    stage: stage
    acsessprincipalId: logicApp.outputs.logicAppPrincipalId
  }
}

module apiManagement 'modules/apiManagement.bicep' = {
  scope: resourceGroup
  params: {
    appName:appName
    functionAppName: functionApp.outputs.functionAppName 
    stage: stage
  }
}
