

param serviceBusName string

param appName string  
param stage string 
param location string = resourceGroup().location
param sku object = {
  name: 'Standard'
  tier: 'Standard'
}
param tags object = {}
param identityType string = 'SystemAssigned' 

var name = toLower('sb-${appName}-${serviceBusName}-${stage}')

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: name
  location: location
  sku: sku
  tags: tags
  identity: {
    type: identityType
  }
  properties: {
   
  }
}

output serviceBusNamespaceId string = serviceBusNamespace.id
output serviceBusNamespaceName string = serviceBusNamespace.name
