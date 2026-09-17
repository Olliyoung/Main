---
tags: [network-1, cisco, packet-tracer, inter-vlan, router-on-a-stick, dhcp, svi, ccna, srwe]
aliases: ["Router on a stick", "Inter-VLAN routing", "DHCP config", "IP helper"]
---
 +
# 03 — Inter-VLAN routing & DHCP

> [!abstract] What & why
> VLANs can't talk to each other without a Layer 3 hop. Two ways: **router‑on‑a‑stick** (one
> router trunk link, one subinterface per VLAN) or a **Layer 3 switch** (`ip routing` + an SVI
> per VLAN). Then **DHCP** hands out addresses per subnet; if the DHCP server is on a
> different subnet than the clients, the router needs `ip helper-address` to relay the
> broadcasts.

## Router-on-a-stick (on the router)

```cisco
configure terminal
! the physical interface carries the tags - bring it up, no IP here
interface GigabitEthernet0/0
 no shutdown
exit
!
! one subinterface per VLAN; the .NN is just convention, the dot1Q tag is what matters
interface GigabitEthernet0/0.10
 encapsulation dot1Q 10
! this address is the default gateway for VLAN 10 hosts
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
! mark the native VLAN's subinterface "native" so untagged frames are handled
 encapsulation dot1Q 40 native
 ip address 192.168.40.1 255.255.255.0
exit
end
write memory
```

## Layer 3 switch (SVIs)

```cisco
configure terminal
! turn on routing between SVIs
ip routing
!
interface vlan 10
 ip address 192.168.10.1 255.255.255.0
 no shutdown
interface vlan 20
 ip address 192.168.20.1 255.255.255.0
 no shutdown
interface vlan 99
 ip address 192.168.99.1 255.255.255.0
 no shutdown
exit
end
write memory
```

## DHCP on a router (+ relay)

```cisco
configure terminal
! never hand out the gateway or the first few addresses
ip dhcp excluded-address 192.168.10.1 192.168.10.10
!
ip dhcp pool Sales
! subnet this pool serves
 network 192.168.10.0 255.255.255.0
! gateway pushed to clients
 default-router 192.168.10.1
 dns-server 8.8.8.8
exit
!
ip dhcp pool IT
 network 192.168.20.0 255.255.255.0
 default-router 192.168.20.1
 dns-server 8.8.8.8
exit
end
write memory
```

```cisco
! --- DHCP relay: on the interface FACING THE CLIENTS, point at the DHCP server ---
interface GigabitEthernet0/0.20
 ip helper-address 192.168.10.5
```

```cisco
! --- make a router interface a DHCP CLIENT instead ---
interface GigabitEthernet0/1
 ip address dhcp
```

> [!warning] Common mistakes
> - **Physical interface still `shutdown`** → all subinterfaces are down.
> - **`encapsulation dot1Q` tag ≠ the switch VLAN ID** → that subinterface gets no traffic.
> - **Forgot `native` on the native‑VLAN subinterface** → untagged frames dropped / native
>   VLAN mismatch.
> - **L3 switch: forgot `ip routing`** → SVIs are up but nothing routes between them.
> - **DHCP clients get nothing across subnets** → missing `ip helper-address` on the
>   client‑side interface.
> - **Address conflicts** → forgot `ip dhcp excluded-address` for the gateway / static hosts.

> [!tip] Verification
> ```cisco
> show ip route                  ! connected routes for every VLAN subnet
> show ip interface brief        ! subinterfaces up/up with the gateway IPs
> show ip dhcp binding           ! leases handed out
> show ip dhcp pool              ! pool usage
> ```
> DHCP pool calc example: `192.168.234.0/27` → 32 total, 30 usable; reserve 22 for phones →
> **8 left** for other hosts.
