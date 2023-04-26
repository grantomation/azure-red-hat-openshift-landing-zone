param location string
param acrPrivateEndpointName string
param acrPrivateEndpointGroupName string
param acrName string
param acrPrivateDnsZoneName string
param spokeRG string
param spokeVnetName string
param computeSubnetName string
param hubRG string

resource spokeVnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: spokeVnetName
  scope: resourceGroup(spokeRG)
}

resource computeSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  name: computeSubnetName
  parent: spokeVnet
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

resource acrPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: acrPrivateDnsZoneName
  scope: resourceGroup(hubRG)
}

resource containerRegistryPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: acrPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: acrPrivateEndpointName
        properties: {
          groupIds: [
            acrPrivateEndpointGroupName
          ]
          privateLinkServiceId: acr.id
        }
      }
    ]
    subnet: {
      id: computeSubnet.id
    }
  }
}

resource privateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  parent: containerRegistryPrivateEndpoint
  name: '${acrPrivateEndpointGroupName}-PrivateDnsZoneGroup'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: acrPrivateDnsZoneName
        properties:{
          privateDnsZoneId: acrPrivateDnsZone.id
        }
      }
    ]
  }
}
