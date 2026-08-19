# Cisco Command Reference

## Basic Setup

- Enter privileged EXEC mode: `enable`
- Enter global configuration mode: `configure terminal`
- Set hostname: `hostname <HOSTNAME>`
- Set encrypted privileged password: `enable secret <PASSWORD>`

## Create VLAN

- Create VLAN: `vlan <VLAN ID>`
- Name VLAN: `name <VLAN NAME>`
- Leave VLAN configuration: `exit`

Example:

vlan 20

name Sales

exit

## Access Ports

- Select one interface: `interface <INTERFACE>`
- Select multiple interfaces: `interface range <INTERFACE RANGE>`
- Set access mode: `switchport mode access`
- Assign VLAN: `switchport access vlan <VLAN ID>`
- Enable port: `no shutdown`
- Disable port: `shutdown`
- Leave interface: `exit`

## Trunk

- Enter interface: `interface <INTERFACE>`
- Set trunk mode: `switchport mode trunk`
- Set native VLAN: `switchport trunk native vlan <VLAN ID>`
- Allow VLANs: `switchport trunk allowed vlan <VLAN LIST>`

## Router-on-a-Stick / Encapsulation

- Enter subinterface: `interface <INTERFACE>.<VLAN ID>`
- Configure 802.1Q: `encapsulation dot1Q <VLAN ID>`
- Configure native VLAN: `encapsulation dot1Q <VLAN ID> native`
- Assign IP address: `ip address <IP ADDRESS> <SUBNET MASK>`

Example:

interface gi0/1.30

encapsulation dot1Q 30

ip address 192.168.30.1 255.255.255.0

## Management SVI

- Enter VLAN interface: `interface vlan <VLAN ID>`
- Assign IP: `ip address <IP ADDRESS> <SUBNET MASK>`
- Enable SVI: `no shutdown`
- Set default gateway: `ip default-gateway <GATEWAY IP>`

## DHCP

- Exclude IP: `ip dhcp excluded-address <IP ADDRESS>`
- Create DHCP pool: `ip dhcp pool <POOL NAME>`
- Set network: `network <NETWORK ADDRESS> <SUBNET MASK>`
- Set gateway: `default-router <GATEWAY IP>`
- Set DNS: `dns-server <DNS IP>`

## Port Security

- Enable port security: `switchport port-security`
- Set maximum MAC addresses: `switchport port-security maximum <NUMBER>`
- Set violation action: `switchport port-security violation <ACTION>`
- Enable sticky MAC: `switchport port-security mac-address sticky`

## Black-Hole VLAN

- Create VLAN: `vlan <VLAN ID>`
- Name it: `name BlackHole`
- Select unused ports: `interface range <INTERFACE RANGE>`
- Set access mode: `switchport mode access`
- Assign VLAN: `switchport access vlan <VLAN ID>`
- Shut ports down: `shutdown`

Example:

vlan 666

name BlackHole

exit

  

interface range fa0/5-10

switchport mode access

switchport access vlan 666

shutdown

## BPDU Guard

- Enter interface: `interface <INTERFACE>`
- Enable BPDU Guard: `spanning-tree portfast bpduguard enable`
- Remove BPDU Guard: `no spanning-tree portfast bpduguard enable`

## EtherChannel / LACP

- Select interfaces: `interface range <INTERFACE RANGE>`
- Set trunk: `switchport mode trunk`
- Add to LACP: `channel-group <CHANNEL NUMBER> mode active`
- Enter Port-Channel: `interface port-channel <CHANNEL NUMBER>`
- Set Port-Channel trunk: `switchport mode trunk`

## SSH

- Set domain: `ip domain-name <DOMAIN NAME>`
- Create user: `username <USERNAME> secret <PASSWORD>`
- Generate RSA key: `crypto key generate rsa`
- Enter VTY lines: `line vty 0 15`
- Allow SSH: `transport input ssh`
- Local authentication: `login local`
- Enable SSH v2: `ip ssh version 2`

## Static Route

- Create static route: `ip route <DESTINATION NETWORK> <SUBNET MASK> <NEXT-HOP IP>`

---

# Short Commands

These are the commands where using the short version is actually useful when working in Packet Tracer.

- **Configure terminal**
    - `conf t` → `configure terminal`
- **Interface**
    - `int fa0/1` → `interface FastEthernet0/1`
    - `int gi0/1` → `interface GigabitEthernet0/1`
- **Interface range**
    - `int range fa0/1-10` → `interface range FastEthernet0/1-10`
- **Exit**
    - `ex` → `exit`
- **No shutdown**
    - `no shut` → `no shutdown`
- **Shutdown**
    - `shut` → `shutdown`
- **Switchport**
    - `sw` → `switchport`
    - `sw mode acc` → `switchport mode access`
    - `sw mode trunk` → `switchport mode trunk`
    - `sw acc vlan <VLAN ID>` → `switchport access vlan <VLAN ID>`
- **Encapsulation**
    - `enc dot1q <VLAN ID>` → `encapsulation dot1Q <VLAN ID>`
- **IP address**
    - `ip add <IP ADDRESS> <SUBNET MASK>` → `ip address <IP ADDRESS> <SUBNET MASK>`
- **Write/save**
    - `wr` → `write memory`

---

# Show Commands

- **Show running configuration**
    - `sh run` → `show running-config`
    - `sh r` → `show running-config`
- **Show VLANs**
    - `sh vlan` → `show vlan`
- **Show IP interfaces**
    - `sh ip int br` → `show ip interface brief`
- **Show interface status**
    - `sh int status` → `show interfaces status`
- **Show trunks**
    - `sh int trunk` → `show interfaces trunk`
- **Show EtherChannel**
    - `sh etherchannel summary` → `show etherchannel summary`
- **Show Spanning Tree**
    - `sh spanning-tree` → `show spanning-tree`
- **Show MAC table**
    - `sh mac address-table` → `show mac address-table`
- **Show port security**
    - `sh port-security` → `show port-security`
- **Show SSH**
    - `sh ip ssh` → `show ip ssh`

---

# Testing

- Ping: `ping <IP ADDRESS>`
- Traceroute: `traceroute <IP ADDRESS>`
- Save: `wr`
- Return to privileged mode: `end`