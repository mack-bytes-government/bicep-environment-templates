param nsg_name string 
param location string
param default_tag_name string
param default_tag_value string

param security_rules array = [
  {
    name: 'AllowVnetInBound'
    properties: {
      priority: 100
      access: 'Allow'
      direction: 'Inbound'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
    }
  }
  {
    name: 'BlockInternetInBound'
    properties: {
      priority: 200
      access: 'Deny'
      direction: 'Inbound'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'Internet'
      destinationAddressPrefix: '*'
    }
  }
  {
    name: 'AllowVnetOutBound'
    properties: {
      priority: 300
      access: 'Allow'
      direction: 'Outbound'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
    }
  }
]

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsg_name
  location: location
  tags: {
    '${default_tag_name}': default_tag_value
  }
  properties: {
    securityRules: security_rules
  }
}

output id string = nsg.id
