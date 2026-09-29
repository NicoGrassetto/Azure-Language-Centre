targetScope = 'subscription'

@description('The azd environment name. Keep it stable between deployments.')
@minLength(1)
@maxLength(64)
param environmentName string

@description('Deployment region from a curated shortlist; verify feature availability and live capacity.')
@allowed([
  'swedencentral'
  'eastus'
  'westeurope'
  'northeurope'
])
@metadata({
  azd: {
    type: 'location'
    default: 'swedencentral'
  }
})
param location string

var resourceToken = uniqueString(subscription().id, 'azure-language-recipes', environmentName, location)
var languageName = 'lang-recipes-${resourceToken}'
var tags = {
  'azd-env-name': environmentName
  workload: 'azure-language-recipes'
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-lang-recipes-${resourceToken}'
  location: location
  tags: tags
}

module language 'br/public:avm/res/cognitive-services/account:0.19.1' = {
  scope: resourceGroup
  params: {
    name: languageName
    location: location
    kind: 'TextAnalytics'
    sku: 'S'
    customSubDomainName: languageName
    // The existing local notebook uses API keys and a public endpoint.
    disableLocalAuth: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
    enableTelemetry: false
    tags: tags
  }
}

@description('The region containing the Language account.')
output AZURE_LOCATION string = location

@description('The resource group managed by this azd environment.')
output AZURE_RESOURCE_GROUP string = resourceGroup.name

@description('The Language account name, used when retrieving a key separately.')
output AZURE_LANGUAGE_NAME string = language.outputs.name

@description('The endpoint consumed by the notebook.')
output AZURE_LANGUAGE_ENDPOINT string = language.outputs.endpoint

@description('The Language account resource ID, usable as an RBAC scope.')
output AZURE_LANGUAGE_RESOURCE_ID string = language.outputs.resourceId