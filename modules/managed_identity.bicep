param identity_name string
param location string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identity_name
  location: location
}

output identityClientId string = managedIdentity.properties.clientId
output identityObjectId string = managedIdentity.properties.principalId
output identityName string = managedIdentity.name
