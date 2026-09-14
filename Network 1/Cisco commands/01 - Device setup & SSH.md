---
tags: [network-1, cisco, packet-tracer, ssh, basic-config, ccna, srwe]
aliases: ["Basic device setup", "SSH config", "banner motd"]
---

# 01 — Device setup & SSH

> [!abstract] What & why
> The first thing you do on every switch and router: name it, protect privileged mode, set
> up a login banner, and turn on SSH so remote admin isn't in clear text. On a switch you
> also give VLAN 1 (or a chosen management VLAN) an IP so you can reach it over the network.

## Basic config (paste block — routers & switches)

```cisco
enable
configure terminal
! name the device
hostname S1
! encrypted privileged-EXEC password
enable secret class
! (optional) refuse passwords shorter than 10 chars
security passwords min-length 10
!
! --- login banner shown before authentication ---
banner motd #
*************************************
* Unauthorized access is prohibited *
* This is a private network device  *
*************************************
#
!
end
write memory
```

## Enable SSH (paste block)

```cisco
configure terminal
! domain name is required before the router will generate an RSA key
ip domain-name ccna-ptsa.com
! local user the SSH clients log in as
username admin secret admin1pass
! generate the crypto key (Packet Tracer will ask for a modulus - answer 2048)
crypto key generate rsa
! force SSH v2 (drops the weaker v1)
ip ssh version 2
!
! --- console line ---
line console 0
 password admin1pass
! authenticate against the local username database
 login local
exit
!
! --- remote (VTY) lines ---
line vty 0 15
! only SSH, no Telnet
 transport input ssh
 login local
exit
end
write memory
```

## Switch management address (SVI)

```cisco
configure terminal
! the virtual interface for the management VLAN (VLAN 1 here, or e.g. VLAN 99)
interface vlan 1
 ip address 192.168.0.101 255.255.255.0
 no shutdown
exit
! the switch's own default gateway (so replies can leave the subnet)
ip default-gateway 192.168.0.1
end
write memory
```

## Enable the access ports (switch)

```cisco
configure terminal
! bring all user ports up
interface range FastEthernet0/1-24
 no shutdown
exit
end
write memory
```

> [!warning] Common mistakes
> - **`crypto key generate rsa` fails** → you forgot `ip domain-name` first.
> - **SSH still lets Telnet in** → `transport input ssh` not set on `line vty`, or set on the
>   wrong line range.
> - **Can't reach the switch remotely** → SVI has an IP but no `no shutdown`, or
>   `ip default-gateway` is missing, or the management VLAN isn't allowed on the trunk
>   (see [[02 - Switching]]).
> - **`login local` without a `username`** → you lock yourself out of the line.

> [!tip] Verification
> ```cisco
> show ip ssh                 ! version 2, key present
> show ip interface brief     ! SVI up/up with the right IP
> show running-config | section line
> ```
