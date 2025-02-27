// Basic Parameters
@description('The project abbreviation')
param project_prefix string 

@description('The environment prefix (dev, test, prod)')
@minLength(1)
@maxLength(100)
param env_prefix string

@description('The location of the resource group')
param location string

// Network Implementation:
@description('The id of an existing network to be passed')
param existing_network_name string

// Subnet Configuration
param project_cidr string = '10.0.1.0/24'
param registry_cidr string = '10.0.2.0/24'
param key_vault_cidr string = '10.0.3.0/24'
param storage_cidr string = '10.0.4.0/24'

// parameters for environment type
// param deploy_data_science_vm bool = false

// Configuration Options for Environment Type:
// param numbers_of_data_science_vm int = 0
// param admin_user_name string
// @secure()
// param admin_user_password string
// param impact_level string = 'IL4'
// param data_science_vm_type string = 'Linux'

// Tag Configuration:
param default_tag_name string
param default_tag_value string



//Deploy into a existing network
module existing_network '../modules/network.bicep' = {
  name: 'existing-network'
  params: {
    location: location
    project_prefix: project_prefix
    env_prefix: env_prefix
    existing_network_name: existing_network_name
    project_cidr: project_cidr
    registry_cidr: registry_cidr
    key_vault_cidr: key_vault_cidr
    storage_cidr: storage_cidr
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
}

module registry '../modules/registry.bicep' = {
  name: 'registry'
  params: {
    acr_name: '${project_prefix}${env_prefix}acr'
    location: location
    subnetId: existing_network.outputs.registry_subnet_id
    vnet_id: existing_network.outputs.id   
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
}

module storage '../modules/storage.bicep' = {
  name: 'storage'
  params: {
    storage_account_name: '${project_prefix}${env_prefix}stg'
    location: location
    subnet_id: existing_network.outputs.storage_subnet_id
    vnet_id: existing_network.outputs.id
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
}

module key_vault '../modules/key-vault.bicep' = {
  name: 'key-vault'
  params: {
    key_vault_name: '${project_prefix}-${env_prefix}-kv'
    location: location
    subnet_id: existing_network.outputs.key_vault_subnet_id
    vnet_id: existing_network.outputs.id
    default_tag_name: default_tag_name
    default_tag_value: default_tag_value
  }
}

output registry_id string = registry.outputs.id
output storage_id string = storage.outputs.id
output key_vault_id string = key_vault.outputs.id
output subnet_project_id string = existing_network.outputs.primary_subnet_id
output subnet_registry_id string = existing_network.outputs.registry_subnet_id
output subnet_key_vault_id string = existing_network.outputs.key_vault_subnet_id
output subnet_storage_id string = existing_network.outputs.storage_subnet_id
output vnet_id string = existing_network.outputs.id
output project_cidr string = project_cidr
output registry_cidr string = registry_cidr
output key_vault_cidr string = key_vault_cidr
output storage_cidr string = storage_cidr

// module data_science_vms '../modules/data-science-virtual-machine.bicep' = [for i in range(0, numbers_of_data_science_vm): if (deploy_data_science_vm) {
//   name: 'dsvm-${i}'
//   params: {
//     vm_name: '${project_prefix}-${env_prefix}-dsvm-${i}'
//     location: location
//     subnet_id: existing_network.outputs.primary_subnet_id
//     vm_image_publisher: 'microsoft-dsvm'
//     vm_image_offer: data_science_vm_type == 'Linux' ? 'ubuntu-2204' : 'dsvm-win-2022'
//     vm_image_sku: data_science_vm_type == 'Linux' ? '2204-gen2' : 'winserver-2022'
//     vm_compute_size: impact_level == 'IL4' ? 'Standard_DS3_v2' : 'F72s_v2'
//     vm_image_version: 'latest'
//     admin_user_name: admin_user_name
//     admin_user_password: admin_user_password
//     default_tag_name: default_tag_name
//     default_tag_value: default_tag_value
//   }
// }]
