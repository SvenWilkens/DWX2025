param location string = resourceGroup().location  
param appName string
param stage string 
param acsessprincipalId string 

resource  communicationServiceConnection 'Microsoft.Web/connections@2016-06-01' existing = {
  name: '${appName}-${stage}-communicationserviceconnection'
  scope: resourceGroup()
}

resource communicationServiceConnectionAccessPolicy 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: '${appName}-${stage}-communicationserviceconnectionaccesspolicy'
  parent: communicationServiceConnection
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        tenantId: subscription().tenantId
        objectId: acsessprincipalId
      }
    }
  }
}


