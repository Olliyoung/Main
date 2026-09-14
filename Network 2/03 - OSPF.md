---
tags: [network-2, cisco, packet-tracer, ospf, routing]
aliases: ["Network 2 OSPF", "Single-area OSPFv2"]
---

# 03 — OSPF (single-area, all routers)

> [!abstract] What & why
> OSPFv2 lets R1–R4 learn each other's networks dynamically and reconverge when a link drops
> — no static routes to maintain. Everything is **area 0**, process `1`. The `network`
> statements use a **wildcard mask** (inverse of the subnet mask). Configured on R2/R3
> together with [[02 - HSRP]] so the redundant gateways can route upstream.
>
> See also: [[00 - Overview & topology]]

## Ready config — R2

```cisco
enable
configure terminal
router ospf 1
! log neighbor up/down events to the console
 log-adjacency-changes
! enable OSPF on the VLAN 10 subinterface (0.0.0.255 = inverse of /24)
 network 192.168.10.0 0.0.0.255 area 0
! VLAN 20 subinterface
 network 192.168.20.0 0.0.0.255 area 0
! the /30 core link (0.0.0.3 = inverse of 255.255.255.252)
 network 10.10.10.0 0.0.0.3 area 0
end
```

## Ready config — R3 (same, but its own core link is 10.10.20.0/30)

```cisco
enable
configure terminal
router ospf 1
 log-adjacency-changes
 network 192.168.10.0 0.0.0.255 area 0
 network 192.168.20.0 0.0.0.255 area 0
! R3's core link is the .20 subnet, not .10
 network 10.10.20.0 0.0.0.3 area 0
end
```

```cisco
! --- OPTIONAL: stop OSPF Hellos toward the LAN hosts (still advertises the subnet) ---
router ospf 1
 passive-interface GigabitEthernet0/0.10
 passive-interface GigabitEthernet0/0.20
```

```cisco
! --- OPTIONAL: edge router injects a default route to the rest of the OSPF domain ---
ip route 0.0.0.0 0.0.0.0 <ISP-next-hop>
router ospf 1
 default-information originate
```

> [!warning] Common mistakes (OSPF)
> - **Wrong wildcard mask** — using the subnet mask (`255.255.255.0`) instead of the inverse
>   (`0.0.0.255`), or `0.0.0.3` vs `0.0.0.255` on the /30 links. It's `255.255.255.255 − subnet mask`.
> - **Mismatched subnet masks on a link** (`/30` one side, `/29` other) → neighbors get stuck
>   in `EXSTART`/`EXCHANGE`, never reach `FULL`.
> - **A `network` statement too wide** that accidentally enables OSPF on a link you didn't mean
>   to (e.g. a future NAT/ISP interface).
> - **Process ID confusion** — the process ID is local‑only, but keep it `1` everywhere to stay
>   sane; the **area must be `0` on every line**.
> - **Underlying interface down** — no adjacency because the two interfaces can't ping each
>   other. Check Layer 2 first, always.
> - **Adjacency `FULL` but no routes** — the far network isn't in a `network` statement, or a
>   transit link got `passive-interface` by mistake.

> [!tip] Verification (OSPF)
> ```cisco
> ! neighbors - want state FULL
> show ip ospf neighbor
> ! process id, router-id, advertised networks, neighbor sources, AD 110
> show ip protocols
> ! per-interface: area, cost, network type, timers, neighbor count
> show ip ospf interface brief
> ! did OSPF routes land in the table? look for "O"
> show ip route ospf
> ```
> **Good:** `show ip ospf neighbor` lists each expected router by ID in state `FULL/  -` (or
> `FULL/DR`, `FULL/BDR`) with `Dead Time` counting down from ~40 s. `show ip route ospf` shows
> `O` routes for the remote VLANs and `10.10.x.x` links.
> **Bad:** neighbor missing (wrong/missing `network` line, or L2 down); stuck `INIT` (Hellos
> one‑way — [[05 - ACL]] dropping `224.0.0.5`, or the far side not configured); stuck `EXSTART`
> (mask/MTU mismatch).

## Troubleshooting checklist (OSPF)

1. **L2 / interface first** — can the two router interfaces ping each other?
2. `show ip ospf neighbor` — neighbor present? `INIT` = one‑way Hellos; `EXSTART` = mask/MTU
   mismatch; missing = `network` statement wrong.
3. `show ip protocols` — is each local subnet in "Routing for Networks"? Wildcard masks right?
4. `show ip ospf interface brief` — area `0` on every interface? timers/type match the neighbor?
5. Adjacency up but routes missing → far end not advertising, or `passive-interface` on a
   transit link.
6. Spokes can't reach the internet → edge router missing `default-information originate`
   (and its own default route).
