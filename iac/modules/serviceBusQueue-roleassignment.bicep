param funcAppPrincipalId  string
param serviceBusName string
param serviceBusQueueName string
param role string = 'Azure Service Bus Data Receiver' 

resource serviceBusReceiverRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: role 
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = {
  name: serviceBusName
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' existing = {
  name: serviceBusQueueName
  parent: serviceBusNamespace
}

resource RBACAzureServiceBusDataReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, serviceBusQueue.id, serviceBusReceiverRoleDefinition.id) 
  scope: serviceBusQueue  // Permission will be set ONLY at the SB Queue level. If scope property is omitted then it is set for the SB Namespace and inherited to all child SB Queues.
  properties: {
    principalId: funcAppPrincipalId 
    roleDefinitionId: serviceBusReceiverRoleDefinition.id
    principalType: 'ServicePrincipal'
  }
}
