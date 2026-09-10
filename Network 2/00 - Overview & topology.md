---
tags: [network-2, cisco, packet-tracer, index, exam-prep]
aliases: ["Network 2 Overview", "ACL NAT HSRP OSPF", "Subject or the assignment"]
---

# Network 2 — Overview & topology

> [!info] What this folder is
> Lab/exam reference for the Network 2 Packet Tracer assignment, built from our real
> troubleshooting session. One note per topic, numbered in the order you actually
> configure and troubleshoot them. Every config block uses the **real addresses from our
> topology** so you can paste and adjust, not rewrite.
>
> `!` comment lines are safe to paste straight into a device.

## Notes in this folder

| # | Note | Covers |
|---|---|---|
| 01 | [[01 - Layer 2 foundation]] | Trunks, EtherChannel, VLANs — **fix this first**, it breaks everything above it |
| 02 | [[02 - HSRP]] | Redundant default gateway on R2 + R3 |
| 03 | [[03 - OSPF]] | Single-area OSPFv2 between R1–R4 |
| 04 | [[04 - NAT and PAT]] | Internet access / overload on R1 + R4 |
| 05 | [[05 - ACL]] | Traffic filtering + NAT selection lists + VTY lockdown |

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
| NAT block | `192.168.200.0` in **/27** steps (`.0 .32 .64 .96 .128 .160 .192`) → mask `255.255.255.224`, wildcard `0.0.0.31` |
| Switches | SW1, SW2, SW3 — interconnected by **EtherChannel `Port-channel1` (Po1)** |

> [!warning] Verify interface names first
> Before pasting anything, run `show ip interface brief` on the device. HWIC modules change
> names (`G0/0/0` vs `G0/0`). Our routers are CISCO2911 → `GigabitEthernet0/0–0/2`.

---

## Master troubleshooting checklist — HSRP not coming up

The exact order that found every fault in our session. Work top‑down; don't skip ahead.

1. **`show interfaces trunk` on every switch.** Does each trunk — the inter‑switch
   `Port-channel1` **and** the `G0/1` up to each router — list `1,10,20`?
   Fix: `interface <trunk>` → `switchport trunk allowed vlan add 10,20` (never without `add`).
   → [[01 - Layer 2 foundation]]
2. **`show vlan brief` on every switch.** Do VLAN 10 and 20 exist? Create them, then re‑add
   to the trunks.
3. **`show spanning-tree vlan 10 | 20`.** Any needed port `BLK` instead of `FWD`?
4. **`show running-config interface g0/0.10` and `.20` on R2 and R3.** Is `encapsulation
   dot1Q <vlan>` present **and** an `ip address` in the right subnet? Do R2 and R3 mirror
   each other (bar the host IP and R2's `priority 110`)? Act on any `% address not within
   subnet` warning. → [[02 - HSRP]]
5. **`show ip interface brief` on R2 and R3.** Subinterface IPs assigned (not `unassigned`),
   parent `G0/0` up/up.
6. **From R2: `ping 192.168.10.3`** (R3's *real* IP, not the virtual IP). Must succeed
   before HSRP can.
7. **`show standby brief` on R2 and R3.** Expect R2 `Active` / R3 `Standby` for groups 10
   and 20, `P` flag set, peer's real IP shown — not `unknown` / `local`.
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

> [!note] How the topics connect
> - [[01 - Layer 2 foundation]] underpins everything: an empty `show standby brief` /
>   `show ip nat translations` / `show ip ospf neighbor` usually means a trunk or
>   subinterface problem, not the protocol.
> - [[02 - HSRP]] ↔ [[03 - OSPF]]: HSRP picks the Active gateway; OSPF gives it a real
>   upstream path. Configure and test them together (fail the Active's uplink, watch
>   Standby take over).
> - [[05 - ACL]] ↔ [[04 - NAT and PAT]]: the NAT selection list is a standard ACL; `/27`
>   LANs use wildcard `0.0.0.31`.
