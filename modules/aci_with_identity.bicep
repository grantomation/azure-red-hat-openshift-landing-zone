param location string
param aciName string
param aciSku string
param aciGroupName string
param loginServer string
param containerBuildName string
param identityName string
var aciImage = '${loginServer}/${containerBuildName}'
param ghRepository string
param ghRunnerName string
param ghPersonalToken string
param keyVaultUri string 
param aciSubnetName string
param hubVnetName string

resource managed_identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: hubVnetName
}

resource aciSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  name: aciSubnetName
  parent: hubVnet
}

resource aro_config_container 'Microsoft.ContainerInstance/containerGroups@2021-10-01' = {
  name: aciName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managed_identity.id}': {
      }
    }
  }
  properties: {
    sku: aciSku
    containers: [
      {
        name: aciGroupName
        properties: {
          image: aciImage
          ports: [
            {
              protocol: 'TCP'
              port: 80
            }
          ]
          environmentVariables: [
            {
                name: 'REPOSITORY'
                value: ghRepository
            }
            {
                name: 'RUNNER_NAME'
                value: ghRunnerName
            }
            {
                name: 'PAT_GITHUB'
                secureValue: ghPersonalToken
            }
            {
                name: 'KV_URI'
                secureValue: keyVaultUri
            }
          ]
          resources: {
            requests: {
              memoryInGB: 1
              cpu: 1
            }
          }
        }
      }
    ]
    initContainers: []
    imageRegistryCredentials: [
      {
        server: loginServer
        identity: managed_identity.id
      }
    ]
    restartPolicy: 'OnFailure'
    ipAddress: {
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
      type: 'Private'
    }
    osType: 'Linux'
    subnetIds: [
      {
        id: aciSubnet.id
      }
    ]
  }
}

output containerName string = aro_config_container.name
