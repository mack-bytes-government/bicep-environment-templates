// Required Parameters:
param project_prefix string
param env_prefix string 
param location string 

// Configuration Paramters:
// Network Implementation:
param existing_network_name string = ''

// Optional Parameters:
param project_cidr string = '10.0.1.0/24'
param registry_cidr string = '10.0.2.0/24'
param key_vault_cidr string = '10.0.3.0/24'
param storage_cidr string = '10.0.4.0/24'

param default_tag_name string
param default_tag_value string

resource virtual_network 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: existing_network_name
}

// Subnet for pod pods
resource default_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${project_prefix}-${env_prefix}-project'
  parent: virtual_network
  properties: {
    addressPrefix: project_cidr
  }
}

resource registry_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${project_prefix}-${env_prefix}-registry'
  parent: virtual_network 
  properties: {
    addressPrefix: registry_cidr
    networkSecurityGroup: {
      id: registry_subnet_nsg.outputs.id
    }
  }
  dependsOn: [ registry_subnet_nsg]
}

module registry_subnet_nsg './subnet-nsg.bicep' = {
  name: '${project_prefix}-${env_prefix}-registry-nsg'
  params: {
    nsg_name: '${project_prefix}-${env_prefix}-registry-nsg'
    location: location
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
}

resource key_vault_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${project_prefix}-${env_prefix}-key-vault'
  parent: virtual_network 
  properties: {
    addressPrefix: key_vault_cidr
    networkSecurityGroup: {
      id: key_vault_subnet_nsg.outputs.id
    }
  }
  dependsOn: [ registry_subnet, key_vault_subnet_nsg]
}

module key_vault_subnet_nsg './subnet-nsg.bicep' = {
  name: '${project_prefix}-${env_prefix}-key-vault-nsg'
  params: {
    nsg_name: '${project_prefix}-${env_prefix}-key-vault-nsg'
    location: location
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
}

resource storage_subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${project_prefix}-${env_prefix}-storage'
  parent: virtual_network 
  properties: {
    addressPrefix: storage_cidr
    networkSecurityGroup: {
      id: storage_subnet_nsg.outputs.id
    }
  }
  dependsOn: [ key_vault_subnet, storage_subnet_nsg]
}

module storage_subnet_nsg './subnet-nsg.bicep' = {
  name: '${project_prefix}-${env_prefix}-storage-nsg'
  params: {
    nsg_name: '${project_prefix}-${env_prefix}-storage-nsg'
    location: location
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
}

output id string = virtual_network.id
output name string = virtual_network.name
output primary_subnet_id string = virtual_network.properties.subnets[0].id
output registry_subnet_id string = registry_subnet.id
output key_vault_subnet_id string = key_vault_subnet.id
output storage_subnet_id string = storage_subnet.id
output registry_subnet_nsg_id string = registry_subnet_nsg.outputs.id
output key_vault_subnet_nsg_id string = key_vault_subnet_nsg.outputs.id
output storage_subnet_nsg_id string = storage_subnet_nsg.outputs.id
