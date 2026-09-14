---
tags: [network-1, cisco, packet-tracer, static-routing, ipv6, loopback, ccna, srwe]
aliases: ["Static route config", "Default route", "Floating static", "IPv6 basics"]
---

# 05 — Static routing & management

> [!abstract] What & why
> Static routes = you tell the router exactly how to reach a network. Good for stub networks
> and small stable topologies. A **default route** (`0.0.0.0/0`) catches everything not in the
> table. A **floating static** has a higher AD than a dynamic route so it only takes over if
> the dynamic route dies. This is the config side — the theory is in
> [[02 - Redundancy & DHCP]] and [[01 - Routing & static routes]].

## Static routes

```cisco
configure terminal
! ip route <destination-network> <mask> <next-hop>
ip route 192.168.4.0 255.255.255.0 192.168.3.2
!
! default route - everything unknown goes to the next hop
ip route 0.0.0.0 0.0.0.0 203.0.113.1
!
! fully specified (exit interface + next-hop) - preferred on Ethernet, no recursive lookup
ip route 0.0.0.0 0.0.0.0 GigabitEthernet0/0 203.0.113.1
!
! floating static backup - AD 95 (higher than OSPF 110? no - pick > the protocol's AD)
ip route 10.0.0.0 255.0.0.0 192.168.1.2 95
end
```

```cisco
! change the next-hop of an existing static: you cannot edit, delete then re-add
no ip route 10.0.0.0 255.0.0.0 172.16.40.2
ip route 10.0.0.0 255.0.0.0 192.168.1.2
```

## IPv6 basics

```cisco
configure terminal
! MUST enable routing first or IPv6 static routes don't install properly
ipv6 unicast-routing
!
interface GigabitEthernet0/0
! enable IPv6 processing on the interface
 ipv6 enable
 ipv6 address 2001:AAAA:BBBB:CCCC::1/64
exit
!
! IPv6 default route
ipv6 route ::/0 2001:AAAA:BBBB:CCCC::2
end
```

## Loopback interface

```cisco
configure terminal
! virtual, always-up interface - handy as a stable router ID / test target
interface Loopback0
 ip address 10.255.255.1 255.255.255.255
exit
end
```

> [!warning] Common mistakes (the ones exams love)
> - **Network address as next‑hop** (e.g. `... 172.16.2.0`) → route never installs.
> - **Wrong interface** (the neighbour's serial instead of yours).
> - **Floating static with AD *lower* than the dynamic protocol** → it wins permanently
>   instead of being a backup. AD `1` is not "floating" — it beats OSPF/EIGRP.
> - **Missing the return route on the other router** → one‑way traffic.
> - **Forgot `ipv6 unicast-routing`** → IPv6 statics silently don't work.
> - **Exit interface goes down** → the config line stays, but the route leaves the table; the
>   router does not invent a new path.

> [!tip] Verification
> ```cisco
> show ip route              ! S = static, S* = default candidate
> show ipv6 route
> show running-config | include ip route
> ```

> [!note] Packet fields leaving a PC (checkpoint favourite)
> - **Destination IP** = the final server — never changes hop to hop.
> - **Destination MAC** = the next‑hop (default gateway on this LAN) — changes every hop.
> - **Source IP** = the PC itself.
