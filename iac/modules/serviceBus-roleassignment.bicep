param funcAppPrincipalId  string
param serviceBusName string
param role string = 'Azure Service Bus Data Receiver'

resource sbNamespace 'Microsoft.ServiceBus/namespaces@2023-01-01-preview' existing = {
  name: serviceBusName
}

var readerRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)

resource logicAppReaderRole 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(sbNamespace.id, funcAppPrincipalId, readerRoleDefinitionId)
  scope: sbNamespace
  properties: {
    roleDefinitionId: readerRoleDefinitionId
    principalId: funcAppPrincipalId
    principalType: 'ServicePrincipal'
  }
}
