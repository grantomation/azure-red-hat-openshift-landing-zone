@description('Set the local VNet name')
param localVnetName string
@description('Set the remote VNet name')
param remoteVnetName string
@description('Sets the remote VNet Resource group')
param rgToPeer string

resource peer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${localVnetName}/peering-to-${remoteVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId(rgToPeer, 'Microsoft.Network/virtualNetworks', remoteVnetName)
    }
  }
}
