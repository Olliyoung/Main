---
tags: [network-2, cisco, packet-tracer, acl, nat, hsrp, ospf, exam-prep]
aliases: ["Network 2 Reference", "ACL NAT HSRP OSPF Notes", "Subject or the assignment"]
---

# ACL, NAT, HSRP & OSPF — Network 2 reference

> [!info] What this file is
> Lab/exam reference for the Network 2 Packet Tracer assignment (ACL · NAT · HSRP · OSPF),
> built from our actual troubleshooting session. Every config block below uses the **real
> addresses from our topology** so you can paste it and adjust, not rewrite from scratch.
>
> Each section has: plain‑language **what & why**, a **ready config** block (every line
> commented with `!`), the **mistakes we actually hit**, **verification** commands with
> good‑vs‑bad output, and a **troubleshooting checklist** ordered by what really went wrong
> — Layer 2 / trunk first, because that's what kept breaking HSRP.
>
> `!` comment lines are safe to paste straight into a device.

---

## Topology & addressing

| Thing | Value |
|---|---|
| VLAN 10 subnet | `192.168.10.0/24` — R2 `.2`, R3 `.3`, **HSRP virtual IP `192.168.10.1`** |
| VLAN 20 subnet | `192.168.20.0/24` — R2 `.2`, R3 `.3`, **HSRP virtual IP `192.168.20.1`** |
| R2 ↔ core link | `10.10.10.0/30` (`255.255.255.252`), R2 `G0/1 = 10.10.10.1` |
| R3 ↔ core link | `10.10.20.0/30`, R3 `G0/2 = 10.10.20.1` |
| HSRP routers | **R2 = priority 110 → Active**, R3 = default 100 → Standby, both `preempt` |
| OSPF | process `1`, everything in **area 0** |
| NAT edge routers | **R1** (LAN `192.168.200.0/27`) and **R4** (LAN `192.168.200.192/27`), both PAT/overload |
| NAT block | `192.168.200.0` stepping in **/27** (`.0 .32 .64 .96 .128 .160 .192`) → mask `255.255.255.224`, wildcard `0.0.0.31` |
| Switches | SW1, SW2, SW3 — interconnected by **EtherChannel `Port-channel1` (Po1)** |

> [!warning] Verify interface names first
> Before pasting anything, run `show ip interface brief` on the device. HWIC modules change
> names (`G0/0/0` vs `G0/0`). Our routers are CISCO2911 → `GigabitEthernet0/0–0/2`.

## Contents

1. [[#1 Layer 2 foundation — trunks, EtherChannel, VLANs]]
2. [[#2 HSRP — redundant default gateway R2 + R3]]
3. [[#3 OSPF — single-area all routers]]
4. [[#4 NAT PAT — internet access R1 + R4]]
5. [[#5 ACL — filtering reference]]
6. [[#Master troubleshooting checklist — HSRP not coming up]]
7. [[#Quick command index]]

---

## 1. Layer 2 foundation — trunks, EtherChannel, VLANs

> [!abstract] What & why
> HSRP, inter‑VLAN routing and the router subinterfaces all ride on VLANs 10/20 crossing the
> switch fabric. If a VLAN isn't carried across **every** trunk in the path — the
> switch‑to‑switch EtherChannel **and** the switch‑to‑router link — the two routers can't hear
> each other's HSRP Hellos and both declare themselves Active. This was the root cause of
> almost every "HSRP is broken" symptom in our session.

### Ready config — switches (run on SW1 / SW2 / SW3 as needed)

```cisco
enable
configure terminal
!
! --- 1. The VLANs must EXIST on the switch before a trunk can carry them ---
vlan 10
 name vlan-10
exit
vlan 20
 name vlan-20
exit
!
! --- 2. Inter-switch EtherChannel: ADD the VLANs, never replace the list ---
interface Port-channel1
! make sure it's a trunk
 switchport mode trunk
! "add" appends 10 and 20; a bare "allowed vlan 10,20" would WIPE VLAN 1 + everything else
 switchport trunk allowed vlan add 10,20
exit
!
! --- 3. The link UP to the router (router-on-a-stick / HSRP) must also be a trunk with 10,20 ---
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan add 10,20
exit
!
end
```

> [!danger] The mistake that cost the most time
> `switchport trunk allowed vlan 10,20` **replaces the entire allowed‑VLAN list** — it silently
> drops VLAN 1 and any other VLAN that was on the trunk. Always use:
> `switchport trunk allowed vlan add 10,20`
> To see the damage / confirm the fix: `show interfaces trunk` → the "Vlans allowed on trunk"
> column must read `1,10,20`, not just `1`.

> [!warning] Common mistakes (Layer 2) — from our session
> - **`allowed vlan` without `add`** — wiped the list, broke everything downstream (see above).
> - **VLAN 10/20 never created on the switch** — `switchport trunk allowed vlan add` "works"
>   but the VLAN isn't active, so frames don't pass. Create `vlan 10` / `vlan 20` first.
> - **Only fixed the switch‑to‑switch trunk (Po1), forgot the switch‑to‑router trunk (G0/1).**
>   HSRP Hellos still didn't reach the far router. Every trunk in the path needs 10 and 20.
> - **Assumed which switch was which.** SW2/SW3 naming was swapped vs. the diagram — always
>   confirm with `show cdp neighbors` / the actual `hostname`, don't trust the label.
> - **Spanning tree blocking a path** — if a redundant link puts a VLAN's port in *blocking*,
>   HSRP multicast can't get through even though the VLAN is "allowed".

> [!tip] Verification (Layer 2)
> ```cisco
> ! which VLANs actually cross each trunk? want: 1,10,20
> show interfaces trunk
> ! do VLAN 10 and 20 exist and have the right access ports?
> show vlan brief
> ! any port stuck BLK (blocking) instead of FWD for VLAN 10 / 20?
> show spanning-tree vlan 10
> show spanning-tree vlan 20
> ```
> **Good:** every trunk in `show interfaces trunk` lists `1,10,20` under both "Vlans allowed
> on trunk" and "Vlans allowed and active in management domain"; STP shows the needed ports
> `FWD`.
> **Bad:** a trunk shows only `1`; or a VLAN 10 port shows `BLK`.

### Troubleshooting checklist (Layer 2)

1. `show interfaces trunk` on **every** switch — does each trunk (Po1 **and** the G0/1 to the
   router) carry `1,10,20`? If not → `switchport trunk allowed vlan add 10,20`.
2. `show vlan brief` — do VLAN 10 and 20 exist? If not → create them, then re‑add to trunks.
3. `show spanning-tree vlan 10 | 20` — any needed port `BLK`? Check for an accidental loop.
4. Confirm you fixed the trunk on **both ends** and on **every hop**, not just one switch.
5. Only then move to [[#2 HSRP — redundant default gateway R2 + R3]].

---

## 2. HSRP — redundant default gateway (R2 + R3)

> [!abstract] What & why
> Hosts in VLAN 10/20 get **one** default gateway. HSRP lets R2 and R3 share a **virtual IP**
> (`192.168.10.1` / `192.168.20.1`) that hosts point at. R2 (priority 110) is **Active** and
> forwards; R3 is **Standby** and takes over in ~10 s if R2's Hellos stop. `preempt` lets R2
> reclaim Active after it recovers. Configured per VLAN subinterface, and paired with
> [[#3 OSPF — single-area all routers]] so both routers actually have a path upstream to fail
> over to.

### Ready config — R2 (Active)

```cisco
enable
configure terminal
!
! --- physical parent interface must be UP before subinterfaces work ---
interface GigabitEthernet0/0
! no IP on the parent; just enable it
 no shutdown
exit
!
! --- VLAN 10 gateway ---
interface GigabitEthernet0/0.10
! tag this subinterface to VLAN 10 (must match the switch VLAN + the trunk allow-list)
 encapsulation dot1Q 10
! THIS ROUTER'S OWN real address in the VLAN 10 subnet - REQUIRED for HSRP to work
 ip address 192.168.10.2 255.255.255.0
! shared virtual IP the hosts use as their default gateway
 standby 10 ip 192.168.10.1
! higher priority => R2 becomes Active
 standby 10 priority 110
! reclaim Active automatically after a reboot / link recovery
 standby 10 preempt
exit
!
! --- VLAN 20 gateway ---
interface GigabitEthernet0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.2 255.255.255.0
 standby 20 ip 192.168.20.1
 standby 20 priority 110
 standby 20 preempt
exit
!
! --- link toward the core (for OSPF) ---
interface GigabitEthernet0/1
 ip address 10.10.10.1 255.255.255.252
 no shutdown
exit
end
```

### Ready config — R3 (Standby)

```cisco
enable
configure terminal
!
interface GigabitEthernet0/0
 no shutdown
exit
!
interface GigabitEthernet0/0.10
 encapsulation dot1Q 10
! R3's own address - different host, same subnet as R2
 ip address 192.168.10.3 255.255.255.0
! SAME group number + SAME virtual IP as R2
 standby 10 ip 192.168.10.1
! no priority line => default 100 => stays Standby while R2 is healthy
 standby 10 preempt
exit
!
interface GigabitEthernet0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.3 255.255.255.0
 standby 20 ip 192.168.20.1
 standby 20 preempt
exit
!
interface GigabitEthernet0/2
 ip address 10.10.20.1 255.255.255.252
 no shutdown
exit
end
```

> [!warning] Common mistakes (HSRP) — from our session
> - **Subinterface had `encapsulation dot1Q` but `no ip address`** (R2 `G0/0.10`). HSRP needs
>   the subinterface to have its **own** IP in the VLAN subnet. Without it HSRP can't operate.
> - **Subinterface missing BOTH `encapsulation dot1Q` and `ip address`** (R2 `G0/0.20`). With
>   no encapsulation the subinterface isn't tagged to VLAN 20 at all — that HSRP group is
>   completely dead.
> - **Ignoring `% Warning: address ... not within subnet` when setting `standby X ip`.** That
>   message was the real clue that the subinterface had no IP in the subnet — not noise.
> - **Both routers show themselves `Active` and the peer as `unknown` / `local`.** They can't
>   hear each other's Hellos → it's a **Layer 2 trunk problem**
>   ([[#1 Layer 2 foundation — trunks, EtherChannel, VLANs]]), not HSRP config.
> - **Testing by pinging the virtual IP.** Ping R3's **real** address (`192.168.10.3`) from R2
>   to test the L2/L3 path — the VIP can be answered locally and hides the problem.
> - **`preempt` missing on R2** — after a reboot R2 comes back as Standby and R3 stays Active.
> - **Priorities/encapsulation not matching between R2 and R3** — the two subinterface configs
>   must mirror each other exactly except for the real host IP and R2's `priority 110`.

> [!tip] Verification (HSRP)
> ```cisco
> ! one line per group: state, virtual IP, priority, preempt flag, peer address
> show standby brief
> ! full detail: peer IP, timers, virtual MAC, active/standby routers
> show standby
> ! did the subinterfaces actually get their IPs? (not "unassigned")
> show ip interface brief
> ```
> **Good:** on R2 `show standby brief` shows groups 10 and 20 as `Active`, `P` (preempt) flag
> set, priority `110`, and **"Standby router" = `192.168.10.3`** (R3's real IP). On R3 the same
> groups show `Standby` with "Active router" = `192.168.10.2`.
> **Bad:** state `Active` on *both* routers with peer `unknown`; or state flapping
> `Speak`/`Listen`; or `show ip interface brief` shows `G0/0.20` as `unassigned`.

### Troubleshooting checklist (HSRP)

1. **Layer 2 path first.** From R2: `ping 192.168.10.3` (R3's *real* IP). Fails →
   [[#Troubleshooting checklist (Layer 2)]]: trunk `allowed vlan add`, VLAN exists, every hop
   including switch→router G0/1, STP not blocking.
2. `show running-config interface g0/0.10` and `.20` on **both** routers — is
   `encapsulation dot1Q` present **and** is there an `ip address` in the right subnet? Do the
   two routers mirror each other?
3. `show ip interface brief` — subinterface IPs assigned, parent `G0/0` up/up?
4. `show standby brief` on both — same **group number** and same **virtual IP**? `preempt` on
   R2? Priority `110` on R2?
5. Did you see and act on any `% address not within subnet` warning?
6. Test failover: `shutdown` R2's `G0/1` (or `G0/0`) and watch R3 take Active in `show standby brief`.

---

## 3. OSPF — single-area (all routers)

> [!abstract] What & why
> OSPFv2 lets R1–R4 learn each other's networks dynamically and reconverge when a link drops
> — no static routes to maintain. Everything is **area 0**, process `1`. The `network`
> statements use a **wildcard mask** (inverse of the subnet mask). Configured on R2/R3
> together with [[#2 HSRP — redundant default gateway R2 + R3]] so the redundant gateways can
> route upstream.

### Ready config — R2

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

### Ready config — R3 (same, but its own core link is 10.10.20.0/30)

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
> - **Different process behaviour expected across routers** — process ID is local, but keep it
>   `1` everywhere to stay sane; **area must be `0` on every line**.
> - **Underlying interface down** — no adjacency because the two interfaces can't ping each
>   other. Check L2 first, always.
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
> one‑way — ACL dropping `224.0.0.5`, or the far side not configured); stuck `EXSTART`
> (mask/MTU mismatch).

### Troubleshooting checklist (OSPF)

1. **L2 / interface first** — can the two router interfaces ping each other?
2. `show ip ospf neighbor` — neighbor present? `INIT` = one‑way Hellos; `EXSTART` = mask/MTU
   mismatch; missing = `network` statement wrong.
3. `show ip protocols` — is each local subnet in "Routing for Networks"? Wildcard masks right?
4. `show ip ospf interface brief` — area `0` on every interface? timers/type match the neighbor?
5. Adjacency up but routes missing → far end not advertising, or `passive-interface` on a
   transit link.
6. Spokes can't reach the internet → edge router missing `default-information originate`
   (and its own default route).

---

## 4. NAT / PAT — internet access (R1 + R4)

> [!abstract] What & why
> R1 and R4 are edge routers. Their LAN hosts use **private** `192.168.200.x/27` addresses
> that can't be routed past the edge, so each router runs **PAT ("NAT overload")**: it
> rewrites every inside source address to its **own outside interface IP** and keeps flows
> apart by **source port number**. One public‑facing address, many inside hosts. The inside
> traffic is selected by a **standard ACL** (see [[#5 ACL — filtering reference]]).

### Ready config — R1 (LAN `192.168.200.0/27`, inside `G0/1`, outside `G0/0`)

```cisco
enable
configure terminal
!
! --- mark the interfaces ---
interface GigabitEthernet0/1
! LAN side = inside
 ip nat inside
exit
interface GigabitEthernet0/0
! link toward the rest of the network = outside
 ip nat outside
exit
!
! --- select which inside addresses get translated (0.0.0.31 = inverse of /27) ---
ip access-list standard NAT_R1_LAN
 permit 192.168.200.0 0.0.0.31
exit
!
! --- translate matched traffic, hide behind G0/0's IP, share via port numbers ---
ip nat inside source list NAT_R1_LAN interface GigabitEthernet0/0 overload
end
```

### Ready config — R4 (LAN `192.168.200.192/27`, inside `G0/1`, outside `G0/2`)

```cisco
enable
configure terminal
!
interface GigabitEthernet0/1
 ip nat inside
exit
interface GigabitEthernet0/2
 ip nat outside
exit
!
ip access-list standard NAT_R4_LAN
 permit 192.168.200.192 0.0.0.31
exit
!
ip nat inside source list NAT_R4_LAN interface GigabitEthernet0/2 overload
end
```

> [!warning] Common mistakes (NAT) — from our session
> - **`/27`, not `/24`.** The block steps in 32s (`.0 .32 .64 .96 .128 .160 .192`) → mask
>   `255.255.255.224`, ACL wildcard **`0.0.0.31`**. Using `0.0.0.255` selects four subnets at
>   once and breaks the intent.
> - **"Overload doesn't work both directions" — expected.** Ping from Laptop0 (behind R3) to
>   Laptop2 (behind R4) fails: both sides overload to their own outside IP and there's **no
>   translation for connections initiated from outside**. Fixing it needs **static NAT / port
>   forwarding** (`ip nat inside source static tcp ...`) — that's the bonus task, not a bug in
>   the base config.
> - **`ip nat inside` / `ip nat outside` missing or on the wrong interface.** Symptom:
>   `show ip nat translations` stays empty. Every path needs one inside and one outside.
> - **Selection ACL doesn't match the LAN** (wrong subnet or wildcard) → those hosts never get
>   translated and their private IPs leak upstream and get dropped.
> - **No default route out of the edge router** → NAT translates fine, packet has nowhere to go.
> - **Guessing interface names** — confirm inside/outside with `show ip interface brief` before
>   applying.

> [!tip] Verification (NAT)
> ```cisco
> ! live translation table - the key command
> show ip nat translations
> ! active count, hits/misses, which interfaces are inside vs outside
> show ip nat statistics
> ! just the NAT lines from the running config
> show run | section nat
> ! clear before a fresh test
> clear ip nat translation *
> ```
> **Good:** after a ping/HTTP test from a laptop, `show ip nat translations` shows rows like
> `icmp 192.168.200.33:12  192.168.200.2:12  <dst>  <dst>` — inside‑local rewritten to the
> outside interface IP, differentiated by port/ID. `show ip nat statistics` lists both an
> inside and an outside interface and `Hits` climbing.
> **Bad:** `Total number of translations: 0` after a real test → interfaces not marked, or the
> ACL doesn't match the source.

### Troubleshooting checklist (NAT)

1. Can the router itself reach the far side (routing / OSPF / default route working)? If not,
   NAT is not the problem yet.
2. `show ip nat statistics` — are **both** inside and outside interfaces listed?
3. `show ip nat translations` after a test — any rows? Empty = ACL miss or missing
   `ip nat inside/outside`.
4. Check the selection ACL: `permit 192.168.200.x` with wildcard **`0.0.0.31`**, right base
   address per router.
5. "Works out, fails in" between two NAT LANs → expected with overload; needs static NAT for
   the specific host.

---

## 5. ACL — filtering reference

> [!abstract] What & why
> An ACL is an ordered list of permit/deny rules checked **top‑to‑bottom**; the first match
> wins and there's an invisible **`deny any`** at the end. Two uses in this course: **select
> traffic** for NAT ([[#4 NAT PAT — internet access R1 + R4]]) and **filter** traffic between
> subnets / lock down VTY.
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
>   ACL. An outbound ACL sees the *translated* (outside) source address.

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

### Troubleshooting checklist (ACL)

1. Does it work with the ACL **removed**? If not, it's not the ACL — go to L2 / routing.
2. `show ip interface <intf>` — ACL applied, right interface, right direction?
3. `show access-lists` — a `permit` covering the wanted traffic, **above** any `deny` that
   would catch it first? Catch‑all present?
4. Every wildcard mask = inverse of the subnet mask; `/27` LANs use `0.0.0.31`.
5. Generate traffic, watch the match counters. No movement on the expected line = traffic
   isn't hitting this ACL.

---

## Master troubleshooting checklist — HSRP not coming up

The exact order that found every fault in our session. Work top‑down; don't skip ahead.

1. **`show interfaces trunk` on every switch.** Does each trunk — the inter‑switch
   `Port-channel1` **and** the `G0/1` up to each router — list `1,10,20`?
   Fix: `interface <trunk>` → `switchport trunk allowed vlan add 10,20` (never without `add`).
2. **`show vlan brief` on every switch.** Do VLAN 10 and 20 exist? Create them, then re‑add
   to the trunks.
3. **`show spanning-tree vlan 10 | 20`.** Any needed port `BLK` instead of `FWD`?
4. **`show running-config interface g0/0.10` and `.20` on R2 and R3.** Is `encapsulation
   dot1Q <vlan>` present **and** an `ip address` in the right subnet? Do R2 and R3 mirror each
   other (bar the host IP and R2's `priority 110`)? Watch for the `% address not within subnet`
   warning — act on it.
5. **`show ip interface brief` on R2 and R3.** Subinterface IPs assigned (not `unassigned`),
   parent `G0/0` up/up.
6. **From R2: `ping 192.168.10.3`** (R3's *real* IP, not the virtual IP). Must succeed before
   HSRP can.
7. **`show standby brief` on R2 and R3.** Expect R2 `Active` / R3 `Standby` for groups 10 and
   20, `P` flag set, peer's real IP shown — not `unknown` / `local`.
8. Still both `Active`? Hellos aren't crossing — go back to step 1, check the *other* end of
   every trunk.

---

## Quick command index

| Task | Command |
|---|---|
| VLANs crossing a trunk (want `1,10,20`) | `show interfaces trunk` |
| VLANs exist + access ports | `show vlan brief` |
| Port blocking a VLAN? | `show spanning-tree vlan 10` |
| Add VLANs to a trunk (don't wipe) | `switchport trunk allowed vlan add 10,20` |
| Interface up? IP assigned? | `show ip interface brief` |
| Full config of one subinterface | `show running-config interface GigabitEthernet0/0.10` |
| HSRP state / who's Active | `show standby brief` |
| HSRP detail (peer, timers, vMAC) | `show standby` |
| L2/L3 path test between routers | `ping 192.168.10.3` (peer's **real** IP) |
| OSPF neighbors (want `FULL`) | `show ip ospf neighbor` |
| OSPF advertised networks / router-id | `show ip protocols` |
| OSPF per-interface (area, cost, timers) | `show ip ospf interface brief` |
| OSPF routes learned | `show ip route ospf` |
| Apply OSPF config/router-id change | `clear ip ospf process` |
| NAT translation table | `show ip nat translations` |
| NAT hits + inside/outside interfaces | `show ip nat statistics` |
| NAT lines from config | `show run | section nat` |
| Clear NAT / ACL counters | `clear ip nat translation *` / `clear access-list counters` |
| ACL rules + hit counters | `show access-lists` |
| ACL on interface + direction | `show ip interface GigabitEthernet0/0.10` |
| Save config | `write memory` (`wr`) |

> [!note] Cross‑topic reminders
> - [[#1 Layer 2 foundation — trunks, EtherChannel, VLANs]] underpins everything: an empty
>   `show standby brief` / `show ip nat translations` / `show ip ospf neighbor` usually means a
>   trunk or subinterface problem, not the protocol.
> - [[#2 HSRP — redundant default gateway R2 + R3]] ↔ [[#3 OSPF — single-area all routers]]:
>   HSRP picks the Active gateway; OSPF gives it a real upstream path. Configure and test them
>   together (fail the Active's uplink, watch Standby take over).
> - [[#5 ACL — filtering reference]] ↔ [[#4 NAT PAT — internet access R1 + R4]]: the NAT
>   selection list is a standard ACL; `/27` LANs use wildcard `0.0.0.31`.
