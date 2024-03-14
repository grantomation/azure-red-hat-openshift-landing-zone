param agentsvcPrivateDnsZoneName string
param monitorPrivateDnsZoneName string
param odsPrivateDnsZoneName string
param omsPrivateDnsZoneName string
param hubVnetName string
param spokeVnetName string
param spokeRG string
param hubRG string

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: hubVnetName
  scope: resourceGroup(hubRG)
}

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: spokeVnetName
  scope: resourceGroup(spokeRG)
}

resource agentSvcDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: agentsvcPrivateDnsZoneName
  location: 'global'
}

resource agentSvcPrivateDnsZoneHubVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: agentSvcDnsZone
  name: uniqueString(hubVnet.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnet.id
    }
  }
}

resource agentSvcPrivateDnsZoneSpokeVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: agentSvcDnsZone
  name: uniqueString(spokeVnet.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: spokeVnet.id
    }
  }
}

resource monitorDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: monitorPrivateDnsZoneName
  location: 'global'
}

resource monitorPrivateDnsZoneHubVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: monitorDnsZone
  name: uniqueString(hubVnet.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnet.id
    }
  }
}

resource monitorPrivateDnsZoneSpokeVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: monitorDnsZone
  name: uniqueString(spokeVnet.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: spokeVnet.id
    }
  }
}

resource odsDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: odsPrivateDnsZoneName
  location: 'global'
}

resource odsPrivateDnsZoneHubVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: odsDnsZone
  name: uniqueString(hubVnet.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnet.id
    }
  }
}

resource odsPrivateDnsZoneSpokeVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: odsDnsZone
  name: uniqueString(spokeVnet.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: spokeVnet.id
    }
  }
}

resource omsDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: omsPrivateDnsZoneName
  location: 'global'
}

resource omsPrivateDnsZoneHubVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: omsDnsZone
  name: uniqueString(hubVnet.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnet.id
    }
  }
}

resource omsPrivateDnsZoneSpokeVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: omsDnsZone
  name: uniqueString(spokeVnet.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: spokeVnet.id
    }
  }
}

output agentsvcPrivateDnsZoneName string = agentsvcPrivateDnsZoneName
output monitorPrivateDnsZoneName string = monitorPrivateDnsZoneName
output odsPrivateDnsZoneName string = odsPrivateDnsZoneName
output omsPrivateDnsZoneName string = omsPrivateDnsZoneName
