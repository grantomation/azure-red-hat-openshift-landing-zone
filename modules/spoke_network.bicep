param location string
param spokeVnetName string
param spokeVnetCidr string
param controlPlaneSubnetCidr string
param computeSubnetCidr string
param tags object
param controlPlaneSubnetName string
param computeSubnetName string
param routeTableName string
param spoke_rg string

resource routeTable_resource 'Microsoft.Network/routeTables@2022-01-01' existing = {
  name: routeTableName
  scope: resourceGroup(spoke_rg)
}

resource cluster_vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: spokeVnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeVnetCidr
      ]
    }
    subnets: [
      {
        name: controlPlaneSubnetName
        properties: {
          addressPrefix: controlPlaneSubnetCidr
          serviceEndpoints: [ { service: 'Microsoft.ContainerRegistry' } ]
          privateLinkServiceNetworkPolicies: 'Disabled'
          routeTable: {
            id: routeTable_resource.id
            location: location
          }
        }
      }
      {
        name: computeSubnetName
        properties: {
          addressPrefix: computeSubnetCidr
          serviceEndpoints: [ { service: 'Microsoft.ContainerRegistry' } ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          routeTable: {
            id: routeTable_resource.id
            location: location
          }
        }
      }
    ]
  }
  dependsOn: [
    routeTable_resource
  ]
}

output spokeVnetName string = spokeVnetName
output computeSubnetName string = computeSubnetName
