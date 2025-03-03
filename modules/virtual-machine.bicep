param vm_name string 
param subnet_id string

// Data Science VM Configuration:
param data_science_vm_type string = 'Linux'

// Disk Image Configuration:
param linux_vm_image_publisher string = 'microsoft-dsvm'
param linux_vm_image_offer string = 'ubuntu-2204'
param linux_vm_image_sku string = '2204-gen2'
param linux_vm_image_version string = 'latest'

param window_vm_image_publisher string = 'microsoft-dsvm'
param window_vm_image_offer string = 'dsvm-win-2022'
param window_vm_image_sku string = 'winserver-2022'
param window_vm_image_version string = 'latest'

param vm_compute_size string = 'Standard_DS3_v2'

// Data Disk Configuration:
param vm_data_disk_size int = 1024

// User Configuration:
param admin_user_name string
@secure()
param admin_user_password string

param default_tag_name string
param default_tag_value string

resource dsVm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vm_name
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    '${default_tag_name}': default_tag_value
  }
  properties: {
    hardwareProfile: {
      vmSize: vm_compute_size
    }
    storageProfile: {
      imageReference: {
        publisher: data_science_vm_type == 'Linux' ? linux_vm_image_publisher : window_vm_image_publisher
        offer: data_science_vm_type == 'Linux' ? linux_vm_image_offer : window_vm_image_offer
        sku: data_science_vm_type == 'Linux' ? linux_vm_image_sku : window_vm_image_sku
        version: data_science_vm_type == 'Linux' ? linux_vm_image_version : window_vm_image_version
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      dataDisks: [
        {
          lun: 0
          createOption: 'Empty'
          diskSizeGB: vm_data_disk_size
          managedDisk: {
            storageAccountType: 'Standard_LRS'
          }
        }
      ]
    }
    osProfile: {
      computerName: vm_name
      adminUsername: admin_user_name
      adminPassword: admin_user_password
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${vm_name}-nic'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet_id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}
