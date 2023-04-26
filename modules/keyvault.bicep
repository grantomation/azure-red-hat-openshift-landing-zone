param keyVaultName string
param location string
param identityObjectId string
param keyVaultDomain string
param aadObjectId string
var keyVaultUri = 'https://${keyVaultName}.${keyVaultDomain}/'
param keyVaultPrivateEndpointName string
param keyVaultPrivateEndpointGroupName string
param spokeVnetName string
param computeSubnetName string
param keyVaultPrivateDnsZoneName string
param spokeRG string
param hubRG string

resource spokeVnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: spokeVnetName
  scope: resourceGroup(spokeRG)
}

resource computeSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  name: computeSubnetName
  parent: spokeVnet
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: keyVaultPrivateDnsZoneName
  scope: resourceGroup(hubRG)
}

resource keyvault_resource 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: identityObjectId
        permissions: {
          secrets: [
            'Get'
          ]
          keys: []
          certificates: []
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: aadObjectId
        permissions: {
          keys: [
            'Get'
            'List'
            'Update'
            'Create'
            'Import'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
            'GetRotationPolicy'
            'SetRotationPolicy'
            'Rotate'
          ]
          secrets: [
            'Get'
            'List'
            'Set'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
          ]
          certificates: [
            'Get'
            'List'
            'Update'
            'Create'
            'Import'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
            'ManageContacts'
            'ManageIssuers'
            'GetIssuers'
            'ListIssuers'
            'SetIssuers'
            'DeleteIssuers'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    vaultUri: keyVaultUri
    publicNetworkAccess: 'Disabled'
  }
}

resource keyVaultPe 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: keyVaultPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: keyVaultPrivateEndpointName
        properties: {
          groupIds: [
            keyVaultPrivateEndpointGroupName
          ]
          privateLinkServiceId: keyvault_resource.id
        }
      }
    ]
    subnet: {
      id: computeSubnet.id
    }
  }
}

resource privateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = {
  parent: keyVaultPe
  name: '${keyVaultPrivateEndpointGroupName}-PrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: keyVaultPrivateDnsZoneName
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZone.id
        }
      }
    ]
  }
}

output keyVaultUri string = keyVaultUri
output keyVaultName string = keyVaultName
