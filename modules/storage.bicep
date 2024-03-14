param location string
param storageAccountName string
param blobContainerName string
param aadObjectId string
param storagePrivateEndpointName string
param computeSubnetName string
param spokeVnetName string
param storagePrivateDnsZoneName string
param identityObjectId string
param storagePrivateEndpointGroupName string
param spokeRG string
param hubRG string

var blobDataContributorRole = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: spokeVnetName
  scope: resourceGroup(spokeRG)
}

resource computeSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: computeSubnetName
  parent: spokeVnet
}

resource storagePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: storagePrivateDnsZoneName
  scope: resourceGroup(hubRG)
}

resource storageAccount_resource 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Disabled'
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource storageAccountBlob 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount_resource
  name: 'default'
  properties: {
    changeFeed: {
      enabled: false
    }
    restorePolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
    isVersioningEnabled: false
  }
}

resource storageAccountBlob_resource 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: storageAccountBlob
  name: blobContainerName
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}


resource storagePe 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: storagePrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: storagePrivateEndpointName
        properties: {
          groupIds: [
            'blob'
          ]
          privateLinkServiceId: storageAccount_resource.id
        }
      }
    ]
    subnet: {
      id: computeSubnet.id
    }
  }
}

resource privateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: storagePe
  name: '${storagePrivateEndpointGroupName}-PrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: storagePrivateDnsZoneName
        properties: {
          privateDnsZoneId: storagePrivateDnsZone.id
        }
      }
    ]
  }
}

resource data_contributor_role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aadObjectId, deployment().name)
  properties: {
    principalId: aadObjectId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', blobDataContributorRole)
  }
  dependsOn: [
    storageAccount_resource
  ]
}

resource managed_identity_role_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, identityObjectId, deployment().name)
  properties: {
    principalId: identityObjectId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', blobDataContributorRole)
  }
  dependsOn: [
    storageAccount_resource
  ]
}


output blobEndpoint string = storageAccount_resource.properties.primaryEndpoints.blob
output blobContainerName string = blobContainerName
output storageAccountName string = storageAccount_resource.name
