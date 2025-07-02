param appServicePlanName string
param appName string 
param stage string
param location string = resourceGroup().location  
param sku object
param isLinux bool = false
param tags object = {}
 

var name = toLower('sp-${appName}-${appServicePlanName}-${stage}')

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: name
  location: location
  sku: sku

  properties: {
    reserved: isLinux
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
  tags: tags
  
}

output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
