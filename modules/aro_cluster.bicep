@secure()
param pullSecret string

@secure()
param aadClientId string

@secure()
param aadClientSecret string

@secure()
param rpObjectId string

param location string
param clusterName string
param tags object
param domain string
param podCidr string
param serviceCidr string
param controlPlaneVmSize string
param computeVmSize string
param computeVmDiskSize int
param computeNodeCount int
param apiServerVisibility string
param ingressVisibility string
param spokeVnetName string
param controlPlaneSubnetName string
param computeSubnetName string
param fipsValidatedModules string
param encryptionAtHost string
param openshiftVersion string

var contribRole = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
param resourceGroupId string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${domain}-${clusterName}-${location}'

resource clusterVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = { name: spokeVnetName }

resource role_for_rpObjectId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, rpObjectId)
  properties: {
    principalId: rpObjectId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contribRole)
  }
  dependsOn: [
    clusterVnet
  ]
}

resource aro 'Microsoft.RedHatOpenShift/openShiftClusters@2023-09-04' = {
  name: clusterName
  location: location
  tags: tags
  properties: {
    clusterProfile: {
      domain: domain
      resourceGroupId: resourceGroupId
      pullSecret: pullSecret
      fipsValidatedModules: fipsValidatedModules
      version: openshiftVersion
    }
    networkProfile: {
      podCidr: podCidr
      serviceCidr: serviceCidr
      outboundType: 'UserDefinedRouting'
    }
    servicePrincipalProfile: {
      clientId: aadClientId
      clientSecret: aadClientSecret
    }
    masterProfile: {
      vmSize: controlPlaneVmSize
      subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', spokeVnetName, controlPlaneSubnetName)
      encryptionAtHost: encryptionAtHost
    }
    workerProfiles: [
      {
        name: 'worker'
        vmSize: computeVmSize
        diskSizeGB: computeVmDiskSize
        subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', spokeVnetName, computeSubnetName)
        count: computeNodeCount
        encryptionAtHost: encryptionAtHost
      }
    ]
    apiserverProfile: {
      visibility: apiServerVisibility
    }
    ingressProfiles: [
      {
        name: 'default'
        visibility: ingressVisibility
      }
    ]
  }
  dependsOn: [
    clusterVnet
    role_for_rpObjectId
  ]
}

output clusterName string = clusterName
