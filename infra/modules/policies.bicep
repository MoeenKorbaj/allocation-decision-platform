// Azure Policy guardrails, assigned at the project resource group only,
// so other workloads in the subscription are unaffected (ADR-10).
targetScope = 'resourceGroup'

param allowedLocation string
param requiredTags array

var builtIn = {
  allowedLocations: 'e56962a6-4747-49cd-b67b-bf8b01975c4c'
  requireTag: '871b6d14-10aa-478d-b590-94f262ecfa99'
  acrAdminDisabled: 'dc921057-6b28-4fbe-9b83-f7bec05db6c2'
  appInsightsEntraOnly: '199d5677-e4d9-4264-9465-efe1839c06bd'
  logAnalyticsEntraOnly: 'e15effd4-2278-4c65-a0da-4d6f6d1890e2'
}

resource allowedLocations 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'adp-allowed-locations'
  properties: {
    displayName: 'ADP - resources only in ${allowedLocation} (ADR-15)'
    policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', builtIn.allowedLocations)
    parameters: {
      listOfAllowedLocations: { value: [allowedLocation] }
    }
  }
}

resource requireTag 'Microsoft.Authorization/policyAssignments@2024-04-01' = [for tag in requiredTags: {
  name: 'adp-require-tag-${tag}'
  properties: {
    displayName: 'ADP - require tag "${tag}"'
    policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', builtIn.requireTag)
    parameters: {
      tagName: { value: tag }
    }
  }
}]

// "No keys": deny resources that accept non-Entra authentication.
var entraOnly = [
  { name: 'adp-deny-acr-admin', def: builtIn.acrAdminDisabled, label: 'Container Registry admin account' }
  { name: 'adp-deny-appi-local-auth', def: builtIn.appInsightsEntraOnly, label: 'Application Insights key-based ingestion' }
  { name: 'adp-deny-log-local-auth', def: builtIn.logAnalyticsEntraOnly, label: 'Log Analytics key-based ingestion' }
]

resource denyLocalAuth 'Microsoft.Authorization/policyAssignments@2024-04-01' = [for p in entraOnly: {
  name: p.name
  properties: {
    displayName: 'ADP - deny ${p.label}'
    policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', p.def)
    parameters: {
      effect: { value: 'Deny' }
    }
  }
}]
