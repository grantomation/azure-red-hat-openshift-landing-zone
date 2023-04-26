param location string
param fw_pip_name string
param fw_pip_sku_type string
param fw_pip_tier_name string
param azfw_name string
param azfw_sku_name string
param azfw_sku_tier string
param azfw_threat_intel_mode string
param azfw_enable_dns string
param hubVnetName string
param fwPrivateIP string

resource fw_pip_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: fw_pip_name
  location: location
  sku: {
    name: fw_pip_sku_type
    tier: fw_pip_tier_name
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource hub_vnet_resource 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: hubVnetName
}

resource azfw_resource 'Microsoft.Network/azureFirewalls@2022-01-01' = {
  name: azfw_name
  location: location
  properties: {
    hubIPAddresses: {
      privateIPAddress: fwPrivateIP
    }
    sku: {
      name: azfw_sku_name
      tier: azfw_sku_tier
    }
    threatIntelMode: azfw_threat_intel_mode
    additionalProperties: {
      'Network.DNS.EnableProxy': azfw_enable_dns
    }
    ipConfigurations: [
      {
        name: '${azfw_name}-ipc'
        properties: {
          publicIPAddress: {
            id: fw_pip_resource.id
          }
          subnet: {
            id: '${hub_vnet_resource.id}/subnets/AzureFirewallSubnet'
          }
        }
      }
    ]
    networkRuleCollections: []
    applicationRuleCollections: [
      {
        name: 'ARO'
        properties: {
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'telemetry'
              protocols: [
                {
                  protocolType: 'Http'
                  port: 80
                }
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              fqdnTags: []
              targetFqdns: [
                'cert-api.access.redhat.com'
                'api.openshift.com'
                'api.access.redhat.com'
                'infogw.api.openshift.com'
              ]
              sourceAddresses: [
                '*'
              ]
              sourceIpGroups: []
            }
            {
              name: 'external_registries'
              protocols: [
                {
                  protocolType: 'Http'
                  port: 80
                }
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              fqdnTags: []
              targetFqdns: [
                '*cloudflare.docker.com'
                '*registry-1.docker.io'
                'apt.dockerproject.org'
                'auth.docker.io'
                '*googleapis.com'
                '*gcr.io'
                '*mcr.microsoft.com'
              ]
              sourceAddresses: [
                '*'
              ]
              sourceIpGroups: []
            }
            {
              name: 'rh_operators'
              protocols: [
                {
                  protocolType: 'Http'
                  port: 80
                }
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              fqdnTags: []
              targetFqdns: [
                'registry.redhat.io'
              ]
              sourceAddresses: [
                '*'
              ]
              sourceIpGroups: []
            }
            {
              name: 'rh_optional'
              protocols: [
                {
                  protocolType: 'Http'
                  port: 80
                }
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              fqdnTags: []
              targetFqdns: [
                '*.quay.io'
                '*quay.io'
                'mirror.openshift.com'
                'api.openshift.com'
                'registry.access.redhat.com'
              ]
              sourceAddresses: [
                '*'
              ]
              sourceIpGroups: []
            }
            {
              name: 'github_optional'
              protocols: [
                {
                  protocolType: 'Http'
                  port: 80
                }
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              fqdnTags: []
              targetFqdns: [
                'github.com'
                '*.githubusercontent.com'
              ]
              sourceAddresses: [
                '*'
              ]
              sourceIpGroups: []
            }
          ]
        }
      }
    ]
    natRuleCollections: []
  }
}


output fwPrivateIP string = fwPrivateIP
