param storagePrivateDnsZoneName string
param hubVnetName string
param spokeVnetName string
param spokeRG string

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: hubVnetName
}

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: spokeVnetName
  scope: resourceGroup(spokeRG)
}

resource storagePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: storagePrivateDnsZoneName
  location: 'global'
}

resource storagePrivateDnsZonespokeVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: storagePrivateDnsZone
  name: uniqueString(spokeVnet.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: spokeVnet.id
    }
  }
}

resource storagePrivateDnsZoneHubVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: storagePrivateDnsZone
  name: uniqueString(hubVnet.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnet.id
    }
  }
}

output storagePrivateDnsZoneName string = storagePrivateDnsZoneName
