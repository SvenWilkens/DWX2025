param location string = resourceGroup().location  
param appName string  
param stage string 


resource communicationService 'Microsoft.Communication/communicationServices@2023-03-31' = {
  name: '${appName}-${stage}-communicationservice'
  location: 'global'
  properties: {
    dataLocation: 'Germany'
    linkedDomains: [
      communicationServiceEmailDomain.id
    ]
  }
}

resource communicationServiceEmail 'Microsoft.Communication/emailServices@2023-03-31' = {
  name: '${appName}-${stage}-communicationserviceemail'
  location: 'global'
  properties: {
    dataLocation: 'Germany'
  }
}

resource communicationServiceEmailDomain 'Microsoft.Communication/emailServices/domains@2023-03-31' = {
  name: 'AzureManagedDomain'
  location: 'global'
  parent: communicationServiceEmail
  properties: {
    domainManagement: 'AzureManaged'
  }
}

resource communicationServiceEmailSender 'Microsoft.Communication/emailServices/domains/senderUsernames@2023-03-31' = {
  name: 'orderservice' //Must match the username
  parent: communicationServiceEmailDomain
  properties: {
    username: 'orderservice'
    displayName: 'Order Service'
  }
}

resource communicationServiceConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: '${appName}-${stage}-communicationserviceconnection'
  location: location
  kind: 'V2'
  properties: {
    api: {
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/acsemail'
    }
    displayName: '${appName}-${stage}-communicationserviceconnection'
    
    parameterValues: {
      api_key: communicationService.listKeys().primaryConnectionString
    }
  }
}

output user string = communicationServiceEmailSender.properties.username
output domain string = communicationServiceEmailDomain.properties.mailFromSenderDomain
output connectionRuntimeUrl string = communicationServiceConnection.properties.connectionRuntimeUrl
output name string = communicationServiceConnection.name
