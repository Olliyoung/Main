---
tags: [network-2, cisco, packet-tracer, acl, security, filtering]
aliases: ["Network 2 ACL", "Access Control Lists"]
---

# 05 — ACL (filtering reference)

> [!abstract] What & why
> An ACL is an ordered list of permit/deny rules checked **top‑to‑bottom**; the first match
> wins and there's an invisible **`deny any`** at the end. Two uses in this course: **select
> traffic** for NAT ([[04 - NAT and PAT]]) and **filter** traffic between subnets / lock down
> VTY.
>
> - **Standard** (`1–99`, or named) — matches **source IP only** → place **near the destination**.
> - **Extended** (`100–199`, or named) — matches source + dest + protocol + port → place **near the source**.
> - **Wildcard mask** = inverse of the subnet mask. `/24`→`0.0.0.255`, `/27`→`0.0.0.31`, `/30`→`0.0.0.3`.

```cisco
! ================= STANDARD NAMED — the NAT selection style we used =================
ip access-list standard NAT_R1_LAN
! one line, matches the whole /27 LAN
 permit 192.168.200.0 0.0.0.31
! (no catch-all needed here: this ACL only SELECTS traffic for NAT, it doesn't filter)
```

```cisco
! ================= STANDARD NAMED — actually FILTERING traffic =================
! Goal: VLAN 20 may not reach VLAN 10; everything else is fine.
! Standard ACL -> nearest the destination (the VLAN 10 subinterface), outbound.
ip access-list standard BLOCK-V20-TO-V10
! drop the source we care about
 deny 192.168.20.0 0.0.0.255
! REQUIRED: without this the hidden "deny any" blocks all other traffic too
 permit any
!
interface GigabitEthernet0/0.10
! "out" = traffic leaving the router toward VLAN 10 hosts
 ip access-group BLOCK-V20-TO-V10 out
```

```cisco
! ================= EXTENDED NAMED — protocol/port control =================
! Goal: from VLAN 10, allow only DNS + web out; deny the rest. Place near the source, inbound.
ip access-list extended V10-WEB-ONLY
 permit udp 192.168.10.0 0.0.0.255 any eq 53
 permit tcp 192.168.10.0 0.0.0.255 any eq 80
! use the port number for HTTPS (keyword isn't always available)
 permit tcp 192.168.10.0 0.0.0.255 any eq 443
! explicit deny so the drop counter is visible (implicit deny shows no hits)
 deny ip any any
!
interface GigabitEthernet0/0.10
 ip access-group V10-WEB-ONLY in
```

```cisco
! ================= LOCK DOWN SSH/TELNET TO THE ROUTER =================
ip access-list standard MGMT-ONLY
 permit 192.168.10.0 0.0.0.255
!
line vty 0 4
! VTY lines use access-class, NOT ip access-group
 access-class MGMT-ONLY in
 transport input ssh
```

```cisco
! ================= EDIT AN ACL WITHOUT DELETING IT =================
ip access-list extended V10-WEB-ONLY
! show the sequence numbers
 do show access-lists V10-WEB-ONLY
! remove line 20
 no 20
! re-insert a corrected line at that position
 15 permit tcp 192.168.10.0 0.0.0.255 any eq 8080
```

> [!warning] Common mistakes (ACL)
> - **Forgot the `permit any` / `permit ip any any` catch‑all** on a filtering ACL → the hidden
>   `deny any` kills everything you didn't list, including your own management traffic.
> - **Wildcard vs subnet mask**, and **/27 vs /24** (`0.0.0.31` vs `0.0.0.255`).
> - **Standard ACL near the source** → also blocks that source from networks you wanted to keep
>   reachable. Standard → near destination; extended → near source.
> - **Wrong direction** (`in` = entering the router here, `out` = leaving the router here).
> - **Rule order** — a broad `permit` above a specific `deny` means the `deny` never runs.
> - **`access-group` on a VTY line** — VTY uses `access-class`.
> - **Numbered ACL edited by retyping `access-list N ...`** — that just appends. Use named ACLs
>   + sequence numbers.
> - **ACL vs NAT order on an interface** — inbound: ACL → NAT → route; outbound: route → NAT →
>   ACL. An outbound ACL sees the *translated* (outside) source address. See [[04 - NAT and PAT]].

> [!tip] Verification (ACL)
> ```cisco
> ! rules + per-line hit counters (best single command)
> show access-lists
> ! which ACL is on an interface, and the direction
> show ip interface GigabitEthernet0/0.10
> ! reset counters for a clean test
> clear access-list counters
> ```
> **Good:** after test traffic, the expected line's `(N matches)` counter climbs — `permit`s on
> allowed flows, `deny`s on blocked flows.
> **Bad:** all matches hit one line (order wrong); or the `permit` you need shows `0 matches`
> while traffic still flows (ACL not applied / wrong interface / wrong direction).

## Troubleshooting checklist (ACL)

1. Does it work with the ACL **removed**? If not, it's not the ACL — go to L2 / routing.
2. `show ip interface <intf>` — ACL applied, right interface, right direction?
3. `show access-lists` — a `permit` covering the wanted traffic, **above** any `deny` that
   would catch it first? Catch‑all present?
4. Every wildcard mask = inverse of the subnet mask; `/27` LANs use `0.0.0.31`.
5. Generate traffic, watch the match counters. No movement on the expected line = traffic
   isn't hitting this ACL.
