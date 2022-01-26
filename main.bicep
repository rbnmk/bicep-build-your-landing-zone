targetScope = 'subscription'

param environment string = 'hub'
param location string = deployment().location

var envConfig = {
    _tags: {
        Customer: 'Robin Corp'
        Solution: 'Corp IT Azure Infrastructure'
    }
    hub: {
        _environmentTags: {
            Environment: 'HUB'
        }
        subscriptionId: subscription().subscriptionId
        resourceGroups: [
            'hub-networking' // IndexNr: 0
            'hub-management' // IndexNr: 1
        ]
        virtualNetworks: [
            {
                name: 'hub-vnet-1'
                addressPrefixes: [
                    '10.0.42.0/23'
                ]
                dnsServers: []
                subnets: [
                    {
                        name: 'AzureBastionSubnet'
                        addressPrefix: '10.0.42.0/25'
                        nsgName: 'hub-nsg-bastion'
                        nsgSecurityRules: [
                            {
                                name: 'AllowSshRdpOutBound'
                                properties: {
                                    protocol: 'Tcp'
                                    sourcePortRange: '*'
                                    sourceAddressPrefix: '*'
                                    destinationPortRanges: [
                                        '22'
                                        '3389'
                                    ]
                                    destinationAddressPrefix: 'VirtualNetwork'  // Change this if you only want to allow access to specific network(s)
                                    access: 'Allow'
                                    priority: 100
                                    direction: 'Outbound'
                                }
                            }
                        ]
                        nsgRulePreset: 'bastion'
                        routeTableName: ''
                        delegations: ''
                        privateEndpointNetworkPolicies: ''
                        privateLinkServiceNetworkPolicies: ''
                        serviceEndpoints: []
                    }
                ]
            }
        ]
    }
}

resource resourceGroups 'Microsoft.Resources/resourceGroups@2021-04-01' = [for (rg, i) in envConfig[environment].resourceGroups: {
    name: rg
    location: location
    tags: union(envConfig._tags, envConfig[environment]._environmentTags)
}]

module network 'modules/network.bicep' = [for (vnet, i) in envConfig[environment].virtualNetworks: {
    name: '${environment}-network-${i + 1}'
    scope: resourceGroups[0] // Select the index nr from the envConfig variable to deploy to the correct RG
    params: {
        vnet: vnet
        tags: union(envConfig._tags, envConfig[environment]._environmentTags)
    }
}]
