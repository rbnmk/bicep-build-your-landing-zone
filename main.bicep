targetScope = 'subscription'

param environment string = 'hub'
param location string = deployment().location

var envConfig = {
    _defaultTags: {
        costCenter: '420'
    }
    hub: {
        subscriptionId: subscription().subscriptionId
        resourceGroups: [
            'hub-networking'
            'hub-management'
        ]
    }
}

resource hub_resourceGroups 'Microsoft.Resources/resourceGroups@2021-04-01' = [for (rg, i) in envConfig[environment].resourceGroups: {
    name: rg
    location: location
}]
