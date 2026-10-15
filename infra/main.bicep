// Allocation Decision Platform - environment infrastructure (Week 0).
// One resource group per azd environment (dev, prod). Every SKU is explicit:
// no module default is allowed to decide a price (see ADR-10).
targetScope = 'subscription'

@minLength(1)
@maxLength(12)
@description('azd environment name, e.g. dev or prod.')
param environmentName string

@allowed(['uaenorth'])
@description('Azure region. Only UAE North is allowed (ADR-15).')
param location string

@description('GitHub repository (owner/name) allowed to deploy through OIDC.')
param githubRepository string = 'MoeenKorbaj/allocation-decision-platform'

@description('Set by azd when the portal container app already exists, so re-provisioning keeps the deployed image.')
param portalExists bool = false

@description('Owner tag value.')
param owner string = 'Moeen Korbaj'

var regionCode = 'uaen'
var suffix = 'adp-${environmentName}-${regionCode}'

var tags = {
  project: 'allocation-decision-platform'
  environment: environmentName
  owner: owner
  dataClassification: 'synthetic'
  costCenter: 'personal'
}

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${suffix}'
  location: location
  tags: union(tags, { 'azd-env-name': environmentName })
}

// Guardrails first. Note: a new policy assignment can take up to ~30 minutes
// to take effect, so it protects every later deployment, not necessarily this first one.
module policies 'modules/policies.bicep' = {
  scope: rg
  name: 'policies'
  params: {
    allowedLocation: location
    requiredTags: ['project', 'environment']
  }
}

module resources 'modules/resources.bicep' = {
  scope: rg
  name: 'resources'
  params: {
    location: location
    environmentName: environmentName
    suffix: suffix
    tags: tags
    githubRepository: githubRepository
    portalExists: portalExists
  }
  dependsOn: [policies]
}

// azd reads these outputs into the environment (.azure/<env>/.env).
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = resources.outputs.registryLoginServer
output AZURE_CONTAINER_REGISTRY_NAME string = resources.outputs.registryName
output SERVICE_PORTAL_NAME string = resources.outputs.portalName
output SERVICE_PORTAL_URI string = resources.outputs.portalUri
output DEPLOY_IDENTITY_CLIENT_ID string = resources.outputs.deployIdentityClientId
