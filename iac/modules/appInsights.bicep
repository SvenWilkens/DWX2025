param location string = resourceGroup().location  
param appName string
param stage string 

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${appName}-${stage}-loganalytics'
  location: location
  properties: {
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appName}-${stage}-appinsights'
  location: location
  properties: {
    WorkspaceResourceId: loganalyticsWorkspace.id
    Application_Type: 'web'
  }
  kind: 'web'
}

output connectionString string = appInsights.properties.ConnectionString
output instrumentationKey string = appInsights.properties.InstrumentationKey
