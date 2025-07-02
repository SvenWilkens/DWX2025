param appName string  
param stage string
param location string = resourceGroup().location
param functionAppName string

resource  functionApp 'Microsoft.Web/sites@2024-11-01' existing = {
  name: functionAppName
}

resource functionAppHost 'Microsoft.Web/sites/host@2022-09-01' existing = {
  name: 'default'
  parent: functionApp
}

resource apiManagement 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: '${appName}-${stage}-apim'
  location: location
  sku: {
    capacity: 1
    name: 'Developer'
  }
  properties: {
    publisherName: 'Sven Wilkens'
    publisherEmail: 'sven-wilkens@outlook.de'
  }
}

resource functionAppKeyNamedValue 'Microsoft.ApiManagement/service/namedValues@2020-12-01' = {
  name: 'functionAppKey'
  parent: apiManagement
  properties: {
    displayName: 'Function-App-Key'
    value: functionAppHost.listKeys().functionKeys.default
    secret: true
  }
}

resource functionAppApiDefinitionReceive 'Microsoft.ApiManagement/service/apis@2022-04-01-preview' = {
  name: 'orderservice'
  parent: apiManagement
  properties: {
    path: 'orderservice'
    description: 'Order Service API'
    displayName: 'Order Service'
    format: 'openapi+json'
    value: loadTextContent('apiManagement/orders/Create-Order.openapi+json.json')
    subscriptionRequired: true
    type: 'http'
    protocols: [ 'https' ]
    serviceUrl: 'https://${functionApp.properties.defaultHostName}/api'
  }
}

resource functionAppApiPolicyReceive 'Microsoft.ApiManagement/service/apis/policies@2022-04-01-preview' = {
  name: 'policy'
  parent: functionAppApiDefinitionReceive
  dependsOn: [
    functionAppKeyNamedValue
  ]
  properties: {
    format: 'rawxml'
    value: loadTextContent('apiManagement/orders/policy.xml')
  }
}

resource functionAppApiDefinitionEmailService 'Microsoft.ApiManagement/service/apis@2022-04-01-preview' = {
  name: 'emailService'
  parent: apiManagement
  properties: {
    path: 'emailservice'
    description: 'Ein Email Serice'
    displayName: 'Email Service'
    format: 'openapi+json'
    value: loadTextContent('apiManagement/email/Create-Order.openapi+json.json')
    subscriptionRequired: true
    type: 'http'
    protocols: [ 'https' ]
    serviceUrl: 'https://${functionApp.properties.defaultHostName}/api'
  }
}

resource functionAppApiPolicyEmailService 'Microsoft.ApiManagement/service/apis/policies@2022-04-01-preview' = {
  name: 'policy'
  parent: functionAppApiDefinitionEmailService
  dependsOn: [
    functionAppKeyNamedValue
  ]
  properties: {
    format: 'rawxml'
    value: loadTextContent('apiManagement/email/policy.xml')
  }
}

resource product 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: 'TestProduct'
  parent: apiManagement
  properties: {
    displayName: 'Test Product'
    description: 'Beispielprodukt via Bicep'
    terms: 'Diese API darf nur intern genutzt werden.'
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 1000
    state: 'published'
  }
}

resource productApi 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  name: functionAppApiDefinitionEmailService.name
  parent: product
  properties: {}
}


