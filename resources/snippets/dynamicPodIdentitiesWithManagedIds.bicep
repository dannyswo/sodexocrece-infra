var podIdentitiesWithManagedIdentities = [for (podIdentity, index) in podIdentities: {
  identity: appsManagedIdentities[index]
  name: podIdentity.podIdentityName
  namespace: podIdentity.podIdentityNamespace
  bindingSelector: podIdentity.podIdentityName
}]

resource appsManagedIdentities 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = [for podIdentity in podIdentities: {
  name: podIdentity.managedIdentityName
  scope: resourceGroup()
}]
