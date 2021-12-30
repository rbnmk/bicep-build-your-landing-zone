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
            'hub-networking'
            'hub-management'
        ]
    }
}

resource hub_resourceGroups 'Microsoft.Resources/resourceGroups@2021-04-01' = [for (rg, i) in envConfig[environment].resourceGroups: {
    name: rg
    location: location
    tags: union(envConfig._tags,envConfig[environment]._environmentTags)
}]
 