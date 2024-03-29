param location string
param frontDoorName string
param fdSku string
param lbFeIpConfig string
param fdPlsId string

resource frontDoor_profile 'Microsoft.Cdn/profiles@2023-07-01-preview' = {
  name: frontDoorName
  location: 'Global'
  sku: {
    name: fdSku
  }
}

resource frontDoor_afd_endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-07-01-preview' = {
  parent: frontDoor_profile
  name: 'afd-${uniqueString(resourceGroup().id)}'
  location: 'Global'
  properties: {
    autoGeneratedDomainNameLabelScope: 'TenantReuse'
    enabledState: 'Enabled'
  }
}

resource frontDoor_afdLbOriginGroup 'Microsoft.Cdn/profiles/originGroups@2023-07-01-preview' = {
  parent: frontDoor_profile
  name: 'afdLbOriginGroup'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'GET'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 120
    }
    sessionAffinityState: 'Disabled'
  }
}

resource frontDoor_afdLbOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2023-07-01-preview' = {
  parent: frontDoor_afdLbOriginGroup
  name: 'afdLbOrigin'
  properties: {
    hostName: lbFeIpConfig
    httpPort: 80
    httpsPort: 443
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    sharedPrivateLinkResource: {
      privateLink: {
        id: fdPlsId
      }
      privateLinkLocation: location
      requestMessage: 'Private link service from AFD'
    }
    enforceCertificateNameCheck: true
  }
}

resource frontDoor_httpd_httpd_route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-07-01-preview' = {
  parent: frontDoor_afd_endpoint
  name: 'httpd-route'
  properties: {
    customDomains: []
    originGroup: {
      id: frontDoor_afdLbOriginGroup.id
    }
    ruleSets: []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Disabled'
    enabledState: 'Enabled'
  }
  dependsOn: [
    frontDoor_afdLbOrigin
  ]
}

output frontDoorName string = frontDoorName
