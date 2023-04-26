var privateDnsZoneName = 'privatelink${environment().suffixes.acrLoginServer}'


resource acrPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

output acrPrivateDnsZoneName string = privateDnsZoneName
