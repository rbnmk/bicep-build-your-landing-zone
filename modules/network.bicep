param vnet object
param tags object = {}

module networkSecurityGroups 'nsg.bicep' = [for i in range(0, length(vnet.subnets)): if (!empty(vnet.subnets[i].nsgName)) {
  name: '${vnet.subnets[i].nsgName}-${i + 1}'
  params: {
      nsgName: vnet.subnets[i].nsgName
      securityRules: vnet.subnets[i].nsgSecurityRules
      rulePreset: vnet.subnets[i].nsgRulePreset
      tags: tags
  }
}]

module network 'vnet.bicep' = {
  name: vnet.name
  params: {
      vnet: vnet
      tags: tags
  }
  dependsOn: [
    networkSecurityGroups
  ]
}
