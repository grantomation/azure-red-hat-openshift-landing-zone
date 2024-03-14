param location string
param sku string
param lawName string
param publicIngest string
param publicQuery string
param plsQueryAccessMode string
param plsIngestionAccessMode string
param amPlsPrivateLinkScopesName string
param lawPrivateEndpointName string
param lawPrivateEndpointGroupName string
param computeSubnetName string
param spokeVnetName string
param monitorPrivateDnsZoneName string
param odsPrivateDnsZoneName string
param omsPrivateDnsZoneName string
param agentsvcPrivateDnsZoneName string
param blobPrivateDnsZoneName string
param hubRG string
param spokeRG string

resource monitorPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: monitorPrivateDnsZoneName
  scope: resourceGroup(hubRG)  
}

resource odsPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: odsPrivateDnsZoneName
  scope: resourceGroup(hubRG)  
}

resource omsPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: omsPrivateDnsZoneName
  scope: resourceGroup(hubRG)  
}

resource agentsvcPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: agentsvcPrivateDnsZoneName
  scope: resourceGroup(hubRG)  
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: blobPrivateDnsZoneName
  scope: resourceGroup(hubRG)  
}

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: spokeVnetName
  scope: resourceGroup(spokeRG)
}

resource computeSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: computeSubnetName
  parent: spokeVnet
}

resource log_analytics_workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: lawName
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: publicIngest
    publicNetworkAccessForQuery: publicQuery
  }
}

resource amPrivateLinkScopes 'microsoft.insights/privatelinkscopes@2021-07-01-preview' = {
  name: amPlsPrivateLinkScopesName
  location: 'global'
  properties: {
    accessModeSettings: {
      exclusions: []
      queryAccessMode: plsQueryAccessMode
      ingestionAccessMode: plsIngestionAccessMode
    }
  }
  dependsOn: [
    log_analytics_workspace
  ]
}

resource amPrivateLinkScopesScopedResource 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  parent: amPrivateLinkScopes
  name: 'scoped-${lawName}'
  properties: {
    linkedResourceId: log_analytics_workspace.id
  }
}

resource lawPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: lawPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: lawPrivateEndpointName
        properties: {
          groupIds: [
            lawPrivateEndpointGroupName
          ]
          privateLinkServiceId: amPrivateLinkScopes.id
        }
      }
    ]
    subnet: {
      id: computeSubnet.id
    }
  }
  dependsOn: [
    log_analytics_workspace
    amPrivateLinkScopesScopedResource
  ]
}

resource amPrivateEndpointDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: lawPrivateEndpoint
  name: '${lawPrivateEndpointGroupName}-default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${lawPrivateEndpointGroupName}-monitor'
        properties: {
          privateDnsZoneId: monitorPrivateDnsZone.id
        }
      }
      {
        name: '${lawPrivateEndpointGroupName}-oms'
        properties: {
          privateDnsZoneId: odsPrivateDnsZone.id
        }
      }
      {
        name: '${lawPrivateEndpointGroupName}-ods'
        properties: {
          privateDnsZoneId: omsPrivateDnsZone.id
        }
      }
      {
        name: '${lawPrivateEndpointGroupName}-agentsvc'
        properties: {
          privateDnsZoneId: agentsvcPrivateDnsZone.id
        }
      }
      {
        name: '${lawPrivateEndpointGroupName}-blob'
        properties: {
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
    ]
  }
}

output lawName string = lawName
