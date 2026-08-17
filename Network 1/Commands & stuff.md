
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
# Cisco Packet Tracer Command Notes

## First steps

- **Enter privileged EXEC mode** `<enable>`
- **Enter global configuration mode** `<conf t>`
- **Set the hostname** `<hostname S1>`
- **Set the encrypted privileged-mode password** `<enable secret pass>`

## Create VLANs

- **Create VLAN 20** `<vlan 20>`
- **Name VLAN 20** `<name VLAN20>`
- **Leave VLAN configuration mode** `<exit>`
- **Create VLAN 30** `<vlan 30>`
- **Name VLAN 30** `<name VLAN30>`
- **Leave VLAN configuration mode** `<exit>`
- **Create VLAN 40** `<vlan 40>`
- **Name VLAN 40** `<name VLAN40>`
- **Leave VLAN configuration mode** `<exit>`

## Configure VLAN 20 access ports

- **Select FastEthernet ports 0/1 through 0/10** `<interface range FastEthernet0/1-10>`
- **Set the ports to access mode** `<switchport mode access>`
- **Assign the ports to VLAN 20** `<switchport access vlan 20>`
- **Enable the ports** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`

## Configure VLAN 30 access ports

- **Select FastEthernet ports 0/11 through 0/20** `<interface range FastEthernet0/11-20>`
- **Set the ports to access mode** `<switchport mode access>`
- **Assign the ports to VLAN 30** `<switchport access vlan 30>`
- **Enable the ports** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`

## Configure VLAN 40 access ports

- **Select FastEthernet ports 0/21 through 0/24** `<interface range FastEthernet0/21-24>`
- **Set the ports to access mode** `<switchport mode access>`
- **Assign the ports to VLAN 40** `<switchport access vlan 40>`
- **Enable the ports** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`

## Configure trunk to router

- **Enter GigabitEthernet 0/1 configuration** `<interface GigabitEthernet0/1>`
- **Set the interface to trunk mode** `<switchport mode trunk>`
- **Set VLAN 40 as the native VLAN** `<switchport trunk native vlan 40>`
- **Allow only VLANs 20, 30 and 40 on the trunk** `<switchport trunk allowed vlan 20,30,40>`
- **Enable the interface** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`

## Configure router-on-a-stick

- **Enter GigabitEthernet 0/1 on the router** `<interface GigabitEthernet0/1>`
- **Enable the physical interface** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`

### VLAN 20 subinterface

- **Enter subinterface G0/1.20** `<interface GigabitEthernet0/1.20>`
- **Set 802.1Q encapsulation for VLAN 20** `<encapsulation dot1Q 20>`
- **Set the VLAN 20 gateway address** `<ip address 192.168.20.1 255.255.255.0>`
- **Leave interface configuration mode** `<exit>`

### VLAN 30 subinterface

- **Enter subinterface G0/1.30** `<interface GigabitEthernet0/1.30>`
- **Set 802.1Q encapsulation for VLAN 30** `<encapsulation dot1Q 30>`
- **Set the VLAN 30 gateway address** `<ip address 192.168.30.1 255.255.255.0>`
- **Leave interface configuration mode** `<exit>`

### VLAN 40 subinterface

- **Enter subinterface G0/1.40** `<interface GigabitEthernet0/1.40>`
- **Set 802.1Q encapsulation for VLAN 40 and make it native** `<encapsulation dot1Q 40 native>`
- **Set the VLAN 40 gateway address** `<ip address 192.168.40.1 255.255.255.0>`
- **Leave interface configuration mode** `<exit>`

## Setup management address (SVI)

- **Enter the VLAN 40 virtual interface** `<interface vlan 40>`
- **Assign the management IP address 192.168.40.2/24 to S1** `<ip address 192.168.40.2 255.255.255.0>`
- **Enable the VLAN 40 interface** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`
- **Set the switch default gateway** `<ip default-gateway 192.168.40.1>`

## Enable switch ports

- **Select FastEthernet ports 0/1 through 0/24** `<interface range FastEthernet0/1-24>`
- **Enable all selected ports** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`

## Check configuration

- **Display VLANs and assigned ports** `<show vlan>`
- **Display trunk configuration** `<show interfaces trunk>`
- **Display interface IP status** `<show ip interface brief>`
- **Display the running configuration** `<show running-config>`

## Port Security

- **Select the access ports** `<interface range FastEthernet0/1-24>`
- **Enable port security** `<switchport port-security>`
- **Allow a maximum of 2 MAC addresses** `<switchport port-security maximum 2>`
- **Shut down the port if a third MAC address is detected** `<switchport port-security violation shutdown>`
- **Automatically learn and save the first MAC addresses** `<switchport port-security mac-address sticky>`
- **Leave interface configuration mode** `<exit>`

## Check Port Security

- **Show port-security status** `<show port-security>`
- **Show port-security information for an interface** `<show port-security interface FastEthernet0/1>`
- **Show learned secure MAC addresses** `<show port-security address>`

## Recover a shutdown port

- **Enter the affected interface** `<interface FastEthernet0/1>`
- **Administratively shut down the port** `<shutdown>`
- **Enable the port again** `<no shutdown>`
- **Leave interface configuration mode** `<exit>`

## Create Black-Hole VLAN

- **Create VLAN 999** `<vlan 999>`
- **Name VLAN 999 BLACKHOLE** `<name BLACKHOLE>`
- **Leave VLAN configuration mode** `<exit>`

## Move unused ports to VLAN 999

- **Select only the unused ports** `<interface range FastEthernet0/x-y>`
- **Set the ports to access mode** `<switchport mode access>`
- **Assign the ports to VLAN 999** `<switchport access vlan 999>`
- **Shut down the unused ports** `<shutdown>`
- **Leave interface configuration mode** `<exit>`

## Enable SSH

- **Set the domain name used for SSH key generation** `<ip domain-name OYL.com>`
- **Create the local user admin with an encrypted password** `<username admin secret pass>`
- **Generate an RSA key pair** `<crypto key generate rsa>`
- **Set the RSA key size to 2048 bits** `<modulus 2048>`
- **Enter VTY line configuration** `<line vty 0 15>`
- **Allow only SSH connections** `<transport input ssh>`
- **Use the local username/password database** `<login local>`
- **Leave VTY line configuration mode** `<exit>`
- **Enable SSH version 2** `<ip ssh version 2>`

## Save configuration

- **Return to privileged EXEC mode** `<end>`
- **Save the running configuration to startup configuration** `<wr>`