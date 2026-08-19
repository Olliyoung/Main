# Reference picture:
![[Pasted image 20260818162718.png]]
# Basic configuration (Routers & Switches)
```
enable
configure terminal
hostname S1
enable secret class

ip domain-name ccna-ptsa.com

username admin secret admin1pass

crypto key generate rsa

ip ssh version 2

line console 0
password admin1pass
login local
exit

line vty 0 15
transport input ssh
login local
exit

banner motd #
*************************************
* Unauthorized access is prohibited *
* This is a private network device  *
*************************************  
#
 
end
 
write memory
```

# Create VLANs (all switches) Example
```
configure terminal
vlan 10
name Sales
vlan 20
name IT
vlan 30
name Management
vlan 40
name Servers
vlan 99
name Native
vlan 666
name BlackHole
exit
end
write memory
```

# BlackHole VLAN 666 (all switches)
```
configure terminal
interface range FastEthernet0/5 - 24
switchport mode access
switchport access vlan 666
shutdown
exit
end
write memory
```

# Access Ports + BPDU Guard (switches)
```
configure terminal
interface range FastEthernet0/1 - 2
switchport mode access
switchport access vlan 10
spanning-tree portfast
spanning-tree bpduguard enable
no shutdown
exit
end
write memory
```

# Trunks (Access switches + Multilayer switches)
```
configure terminal
interface GigabitEthernet0/1
switchport mode trunk
switchport trunk native vlan 99
switchport trunk allowed vlan 10,20,30,40,99
no shutdown
exit
end
write memory
```

# EtherChannel (both Multilayer switches)
```
configure terminal
interface range FastEthernet0/1 - 4
switchport trunk encapsulation dot1q
switchport mode trunk
switchport trunk native vlan 99
channel-group 1 mode active
no shutdown
exit

interface Port-channel 1
switchport trunk encapsulation dot1q
switchport mode trunk
switchport trunk native vlan 99
exit
end
write memory
```

# SVIs + Routing (Multilayer switches)
```
configure terminal
ip routing

interface vlan 10
ip address 192.168.10.1 255.255.255.0
no shutdown

interface vlan 20
ip address 192.168.20.1 255.255.255.0
no shutdown

interface vlan 30
ip address 192.168.30.1 255.255.255.0
no shutdown

interface vlan 40
ip address 192.168.40.1 255.255.255.0
no shutdown

interface vlan 99
ip address 192.168.99.1 255.255.255.0
no shutdown
exit
end
write memory
```

# Router-on-a-Stick (On Router)
```
configure terminal
interface GigabitEthernet0/0
no shutdown
exit

interface GigabitEthernet0/0.10
encapsulation dot1Q 10
ip address 192.168.10.1 255.255.255.0
exit

interface GigabitEthernet0/0.20
encapsulation dot1Q 20
ip address 192.168.20.1 255.255.255.0
exit

interface GigabitEthernet0/0.30
encapsulation dot1Q 30
ip address 192.168.30.1 255.255.255.0
exit

interface GigabitEthernet0/0.40
encapsulation dot1Q 40
ip address 192.168.40.1 255.255.255.0
exit

interface GigabitEthernet0/0.99
encapsulation dot1Q 99
ip address 192.168.99.1 255.255.255.0
exit
end
write memory
```

# DHCP on Router + IP Helper
```
configure terminal
ip dhcp excluded-address 192.168.10.1 192.168.10.10
ip dhcp pool Sales
network 192.168.10.0 255.255.255.0
default-router 192.168.10.1
dns-server 8.8.8.8
exit

ip dhcp pool IT
network 192.168.20.0 255.255.255.0
default-router 192.168.20.1
dns-server 8.8.8.8
exit

ip dhcp pool Management
network 192.168.30.0 255.255.255.0
default-router 192.168.30.1
dns-server 8.8.8.8
exit

ip dhcp pool Servers
network 192.168.40.0 255.255.255.0
default-router 192.168.40.1
dns-server 8.8.8.8
exit

ip dhcp pool NewNetwork
network 192.168.50.0 255.255.255.0
default-router 192.168.50.1
dns-server 8.8.8.8
exit
end
write memory
```




