@description('Bicep module to create a Service Bus Queue with Managed Identity')
param serviceBusName string 
param queueName string = 'myQueue' 
param appName string  


resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = {
  name: serviceBusName
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2021-11-01' = {
  parent: serviceBusNamespace
  name: '${appName}-${queueName}'
  properties: {
  
    maxDeliveryCount: 10
    lockDuration: 'PT5M' 
  }
}

output serviceBusQueueId string = serviceBusQueue.id 
output serviceBusQueueName string = serviceBusQueue.name


