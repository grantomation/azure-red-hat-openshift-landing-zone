param location string
param fdPlsName string
param lbFeIpConfig string
param computeSubnetName string
param spokeVnetName string

resource spokeVnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: spokeVnetName
}

resource computeSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  name: computeSubnetName
  parent: spokeVnet
}

resource fdPls_resource 'Microsoft.Network/privateLinkServices@2022-09-01' = {
  name: fdPlsName
  location: location
  properties: {
    enableProxyProtocol: false
    loadBalancerFrontendIpConfigurations: [
      {
        id: lbFeIpConfig
      }
    ]
    ipConfigurations: [
      {
        name: '${fdPlsName}_ipconfig_0'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: computeSubnet.id
          }
          primary: true
    
        }
      }
    ]
  }
}

output fdPlsName string = fdPlsName
