@description('Object parameter containing all information for the VNET')
param vnet object
param location string = resourceGroup().location
param tags object = {}

var rtId = [for i in range(0, length(vnet.subnets)): {
  id: resourceId('Microsoft.Network/routeTables', vnet.subnets[i].routeTableName)
}]
var nsgId = [for i in range(0, length(vnet.subnets)): {
  id: resourceId('Microsoft.Network/networkSecurityGroups', vnet.subnets[i].nsgName)
}]
var subnets = [for i in range(0, length(vnet.subnets)): {
  name: vnet.subnets[i].name
  properties: {
    addressPrefix: vnet.subnets[i].addressPrefix
    networkSecurityGroup: empty(vnet.subnets[i].nsgName) ? json('null') : nsgId[i]
    routeTable: (empty(vnet.subnets[i].routeTableName) ? json('null') : rtId[i])
    delegations: (empty(vnet.subnets[i].delegations) ? json('null') : vnet.subnets[i].delegations)
    serviceEndpoints: (empty(vnet.subnets[i].serviceEndpoints) ? json('null') : vnet.subnets[i].serviceEndpoints)
    privateEndpointNetworkPolicies: (empty(vnet.subnets[i].privateEndpointNetworkPolicies) ? privateEndpointNetworkPolicyDefault : vnet.subnets[i].privateEndpointNetworkPolicies)
    privateLinkServiceNetworkPolicies: (empty(vnet.subnets[i].privateLinkServiceNetworkPolicies) ? privateLinkServiceNetworkPolicyDefault : vnet.subnets[i].privateLinkServiceNetworkPolicies)
  }
}]
var privateEndpointNetworkPolicyDefault = 'Enabled'
var privateLinkServiceNetworkPolicyDefault = 'Enabled'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnet.name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vnet.addressPrefixes
    }
    dhcpOptions: {
      dnsServers: vnet.DnsServers
    }
    subnets: subnets
  }
}

output virtualNetworkId string = virtualNetwork.id
output virtualNetworkName string = virtualNetwork.name
output virtualNetworkSubnets array = virtualNetwork.properties.subnets
output virtualNetwork object = virtualNetwork
