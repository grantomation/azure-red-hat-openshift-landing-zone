param location string
@description('Name for the public IP of the bastion service')
param bastion_ip_name string
@description('Name for the bastion service')
param bastion_service_name string
param hubVnetName string
param bastionSubnetName string = 'AzureBastionSubnet'

resource bastion_pip_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: bastion_ip_name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion_service_name_resource 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: bastion_service_name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastion_ip_config'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastion_pip_resource.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, bastionSubnetName)
          }
        }
      }
    ]
  }
}
