param routeTableName string
param location string
param routeTableAddressPrefix string
param routeTableNextHopType string
param fwPrivateIP string

resource routeTable_resource 'Microsoft.Network/routeTables@2020-11-01' = {
name: routeTableName
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: routeTableName
        properties: {
          addressPrefix: routeTableAddressPrefix
          nextHopType: routeTableNextHopType
          nextHopIpAddress: fwPrivateIP
          hasBgpOverride: false
        }
      }
    ]
  }
}

output routeTableName string = routeTableName
