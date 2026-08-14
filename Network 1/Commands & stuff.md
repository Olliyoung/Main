
# S1 Configuration

## First steps

- **Enter privileged EXEC mode** `<enable>`
- **Enter global configuration mode** `<conf t>`
- **Set the switch hostname to S1** `<hostname S1>`
- **Set the encrypted privileged-mode password** `<enable secret pass>`

## Enable SSH

- **Set the domain name used for SSH key generation** `<ip domain-name OYL.com>`
- **Generate an RSA key pair for SSH** `<crypto key generate rsa>`
- **Set the RSA key size to 2048 bits** `<modulus 2048>`
- **Create the local user `admin` with an encrypted password** `<username admin secret pass>`
- **Enter VTY line configuration for remote connections** `<line vty 0 15>`
- **Allow only SSH connections on the VTY lines** `<transport input ssh>`
- **Use the local username/password database for authentication** `<login local>`
- **Leave VTY line configuration mode** `<exit>`

## Setup management address (SVI)

- **Enter the configuration for VLAN 1's virtual interface** `<interface vlan 1>`
- **Assign the management IP address 192.168.0.101/24 to S1** `<ip address 192.168.0.101 255.255.255.0>`
- **Enable the VLAN 1 interface** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`

## Enable switch ports

- **Select FastEthernet ports 0/1 through 0/24** `<interface range FastEthernet0/1-24>`
- **Enable all selected ports** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`

## Save configuration

- **Save the running configuration to startup configuration** `<wr>`

# S2 Configuration

## First steps

- **Enter privileged EXEC mode** `<enable>`
- **Enter global configuration mode** `<conf t>`
- **Set the switch hostname to S2** `<hostname S2>`
- **Set the encrypted privileged-mode password** `<enable secret pass>`

## Enable SSH

- **Set the domain name used for SSH key generation** `<ip domain-name OYL.com>`
- **Generate an RSA key pair for SSH** `<crypto key generate rsa>`
- **Set the RSA key size to 2048 bits** `<modulus 2048>`
- **Create the local user `admin` with an encrypted password** `<username admin secret pass>`
- **Enter VTY line configuration for remote connections** `<line vty 0 15>`
- **Allow only SSH connections on the VTY lines** `<transport input ssh>`
- **Use the local username/password database for authentication** `<login local>`
- **Leave VTY line configuration mode** `<exit>`

## Setup management address (SVI)

- **Enter the configuration for VLAN 1's virtual interface** `<interface vlan 1>`
- **Assign the management IP address 192.168.0.102/24 to S2** `<ip address 192.168.0.102 255.255.255.0>`
- **Enable the VLAN 1 interface** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`

## Enable switch ports

- **Select FastEthernet ports 0/1 through 0/24** `<interface range FastEthernet0/1-24>`
- **Enable all selected ports** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`

## Save configuration

- **Save the running configuration to startup configuration** `<wr>`

# Router configuration

## First steps

- **Set the router's hostname** `<hostname R<router number>>`
- **Set the encrypted privileged-mode password** `<enable secret class>`

## Interfaces

- **Enter the GigabitEthernet interface configuration** `<interface Gi0/<interface number>>`
- **Add a description showing which network connects to the router** `<description Net<network number> - til R<router number>>`
- **Assign an IP address and /27 subnet mask to the interface** `<ip address 192.168.200.<host address> 255.255.255.224>`

# DHCP Configuration

## Exclude addresses

- **Prevent a single IP address from being assigned by DHCP** `<ip dhcp excluded-address <exclusion from ip address>>`
- **Prevent a range of IP addresses from being assigned by DHCP** `<ip dhcp excluded-address <exclusion from ip address> <exclusion to ip address>>`

## Create DHCP pool

- **Create and enter a DHCP pool** `<ip dhcp pool <dhcp pool name>>`
- **Define the network and subnet mask that DHCP will use** `<network <ip address> <subnetmask>>`
- **Tell DHCP clients which default gateway to use** `<default-router <gateway-ip>>`
- **Tell DHCP clients which DNS server to use** `<dns-server <DNS-ip>>`
- **Give DHCP clients the domain name** `<domain-name <domain name>>`

# Close unused ports on switches

- **Select a range of switch interfaces** `<interface range <interface>0/<from>-<to>>`
- **Administratively disable the selected ports** `<shutdown>`

# Setup management address (Switch Virtual Interface (SVI))

- **Enter global configuration mode** `<conf t>`
- **Enter the VLAN interface configuration** `<interface vlan <vlan number>>`
- **Give the VLAN interface a name/description** `<name <vlan name>>`
- **Assign an IP address and subnet mask to the SVI** `<ip address <vlan's ip address> <subnet mask>>`
- **Enable the SVI** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`
- **Set the switch's default gateway** `<ip default-gateway <gateway for switch>>`

# Static Routes

- **Create a static route to a destination network** `<ip route <destination network> <subnet mask> <next-hop>>`

# Enable SSH on network device

- **Set the domain name used by SSH** `<ip domain-name <whatever.com>>`
- **Generate an RSA key pair for SSH** `<crypto key generate rsa>`
- **Set the RSA key size to 2048 bits** `<2048>`