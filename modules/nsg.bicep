param nsgName string
@allowed([
  ''
  'bastion'
])
param rulePreset string = ''
param securityRules array = []
param tags object = {}

var defaultSecurityRules = {
  bastion: [
    {
      name: 'AllowHttpsInBound'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        sourceAddressPrefix: 'Internet'
        destinationPortRange: '443'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 600
        direction: 'Inbound'
      }
    }
    {
      name: 'AllowGatewayManagerInBound'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        sourceAddressPrefix: 'GatewayManager'
        destinationPortRange: '443'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 610
        direction: 'Inbound'
      }
    }
    {
      name: 'AllowLoadBalancerInBound'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        sourceAddressPrefix: 'AzureLoadBalancer'
        destinationPortRange: '443'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 620
        direction: 'Inbound'
      }
    }
    {
      name: 'AllowBastionHostCommunicationInBound'
      properties: {
        protocol: '*'
        sourcePortRange: '*'
        sourceAddressPrefix: 'VirtualNetwork'
        destinationPortRanges: [
          '8080'
          '5701'
        ]
        destinationAddressPrefix: 'VirtualNetwork'
        access: 'Allow'
        priority: 630
        direction: 'Inbound'
      }
    }
    {
      name: 'DenyAllInBound'
      properties: {
        protocol: '*'
        sourcePortRange: '*'
        sourceAddressPrefix: '*'
        destinationPortRange: '*'
        destinationAddressPrefix: '*'
        access: 'Deny'
        priority: 1000
        direction: 'Inbound'
      }
    }
    {
      name: 'AllowAzureCloudCommunicationOutBound'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        sourceAddressPrefix: '*'
        destinationPortRange: '443'
        destinationAddressPrefix: 'AzureCloud'
        access: 'Allow'
        priority: 600
        direction: 'Outbound'
      }
    }
    {
      name: 'AllowBastionHostCommunicationOutBound'
      properties: {
        protocol: '*'
        sourcePortRange: '*'
        sourceAddressPrefix: 'VirtualNetwork'
        destinationPortRanges: [
          '8080'
          '5701'
        ]
        destinationAddressPrefix: 'VirtualNetwork'
        access: 'Allow'
        priority: 610
        direction: 'Outbound'
      }
    }
    {
      name: 'AllowGetSessionInformationOutBound'
      properties: {
        protocol: '*'
        sourcePortRange: '*'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: 'Internet'
        destinationPortRanges: [
          '80'
          '443'
        ]
        access: 'Allow'
        priority: 620
        direction: 'Outbound'
      }
    }
    {
      name: 'DenyAllOutBound'
      properties: {
        protocol: '*'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Deny'
        priority: 1000
        direction: 'Outbound'
      }
    }
  ]
}
var rulePresetSelect = defaultSecurityRules[rulePreset]

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsgName
  location: resourceGroup().location
  tags: tags
  properties: {
    securityRules: length(rulePreset) > 0 ?  union(securityRules, rulePresetSelect) : securityRules
  }
}

output networkSecurityGroupName string = networkSecurityGroup.name
output networkSecurityGroupId string = networkSecurityGroup.id
