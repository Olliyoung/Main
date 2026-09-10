---
tags: [network-2, cisco, packet-tracer, index, exam-prep]
aliases: ["Network 2 Overview", "ACL NAT HSRP OSPF", "Subject or the assignment"]
---

# Network 2 — Overview & topology

> [!info] What this folder is
> Lab/exam reference for the Network 2 Packet Tracer assignment, built from our real
> troubleshooting session. One note per topic, numbered in the order you actually configure
> and troubleshoot them. Config blocks use the **real addresses from our topology**.
> `!` comment lines are safe to paste straight into a device.

---

## 1. Notes in this folder

| # | Note | Covers |
|---|---|---|
| 01 | [[01 - Layer 2 foundation]] | Trunks, EtherChannel, VLANs — **fix this first** |
| 02 | [[02 - HSRP]] | Redundant default gateway on R2 + R3 |
| 03 | [[03 - OSPF]] | Single-area OSPFv2 between R1–R4 |
| 04 | [[04 - NAT and PAT]] | Internet access / overload on R1 + R4 |
| 05 | [[05 - ACL]] | Traffic filtering, NAT selection lists, VTY lockdown |

---

## 2. Devices & addressing

### Routers — role

| Router | Role |
|---|---|
| R1 | NAT edge (PAT / overload) |
| R2 | HSRP **Active** (priority 110) · OSPF |
| R3 | HSRP Standby (priority 100, default) · OSPF |
| R4 | NAT edge (PAT / overload) |

### Interface addressing

| Device | Interface | IP | Mask | Purpose |
|---|---|---|---|---|
| R2 | G0/0.10 | 192.168.10.2 | /24 | VLAN 10 gateway (HSRP member) |
| R2 | G0/0.20 | 192.168.20.2 | /24 | VLAN 20 gateway (HSRP member) |
| R2 | G0/1 | 10.10.10.1 | /30 | Core link → OSPF |
| R3 | G0/0.10 | 192.168.10.3 | /24 | VLAN 10 gateway (HSRP member) |
| R3 | G0/0.20 | 192.168.20.3 | /24 | VLAN 20 gateway (HSRP member) |
| R3 | G0/2 | 10.10.20.1 | /30 | Core link → OSPF |
| R1 | G0/1 | *(in LAN 192.168.200.0/27)* | /27 | NAT **inside** |
| R1 | G0/0 | *(uplink)* | — | NAT **outside** |
| R4 | G0/1 | *(in LAN 192.168.200.192/27)* | /27 | NAT **inside** |
| R4 | G0/2 | *(uplink)* | — | NAT **outside** |

### HSRP groups

| Group | VLAN | Virtual IP (host default gateway) | Active | Standby |
|---|---|---|---|---|
| 10 | 10 | 192.168.10.1 | R2 (priority 110) | R3 |
| 20 | 20 | 192.168.20.1 | R2 (priority 110) | R3 |

Both routers have `preempt` set.

### OSPF (process 1, area 0)

| Router | Networks advertised into area 0 |
|---|---|
| R2 | 192.168.10.0/24 · 192.168.20.0/24 · 10.10.10.0/30 |
| R3 | 192.168.10.0/24 · 192.168.20.0/24 · 10.10.20.0/30 |

### NAT

| Router | Inside LAN | Inside if | Outside if | Method |
|---|---|---|---|---|
| R1 | 192.168.200.0/27 | G0/1 | G0/0 | PAT (`overload`) |
| R4 | 192.168.200.192/27 | G0/1 | G0/2 | PAT (`overload`) |

### Switches

SW1, SW2, SW3 — interconnected by EtherChannel **`Port-channel1` (Po1)**.
VLAN 10 and 20 must be allowed on **every** trunk: `Po1` between switches **and** the
`G0/1` from each switch up to its router.

---

## 3. Subnetting & interface-name notes

> [!warning] The NAT block is /27, not /24
> `192.168.200.0` is carved into **/27** subnets that step in 32s:
> `.0 · .32 · .64 · .96 · .128 · .160 · .192`
> → subnet mask `255.255.255.224`, ACL wildcard **`0.0.0.31`**.

> [!warning] Verify interface names before pasting
> Run `show ip interface brief` first. HWIC modules change names (`G0/0/0` vs `G0/0`).
> Our routers are CISCO2911 → `GigabitEthernet0/0–0/2`.

---

## 4. Master troubleshooting checklist — HSRP not coming up

The exact order that found every fault in our session. Work top‑down; don't skip ahead.

1. **`show interfaces trunk`** on every switch.
   Does each trunk — `Port-channel1` **and** the `G0/1` up to each router — list `1,10,20`?
   Fix: `switchport trunk allowed vlan add 10,20` (never without `add`). → [[01 - Layer 2 foundation]]

2. **`show vlan brief`** on every switch.
   Do VLAN 10 and 20 exist? Create them, then re‑add to the trunks.

3. **`show spanning-tree vlan 10`** / **`vlan 20`**.
   Any needed port `BLK` instead of `FWD`?

4. **`show running-config interface g0/0.10`** and **`.20`** on R2 and R3.
   `encapsulation dot1Q <vlan>` present **and** an `ip address` in the right subnet?
   Do R2 and R3 mirror each other (bar the host IP and R2's `priority 110`)?
   Act on any `% address not within subnet` warning. → [[02 - HSRP]]

5. **`show ip interface brief`** on R2 and R3.
   Subinterface IPs assigned (not `unassigned`); parent `G0/0` up/up.

6. **`ping 192.168.10.3` from R2** — R3's *real* IP, not the virtual IP.
   Must succeed before HSRP can.

7. **`show standby brief`** on R2 and R3.
   Expect R2 `Active` / R3 `Standby` for groups 10 and 20, `P` flag set, peer's real IP
   shown — not `unknown` / `local`.

8. **Still both `Active`?**
   Hellos aren't crossing — back to step 1, check the *other* end of every trunk.

---

## 5. Quick command index

### Layer 2

| Task | Command |
|---|---|
| VLANs crossing a trunk (want `1,10,20`) | `show interfaces trunk` |
| VLANs exist + access ports | `show vlan brief` |
| Port blocking a VLAN? | `show spanning-tree vlan 10` |
| Add VLANs to a trunk (don't wipe) | `switchport trunk allowed vlan add 10,20` |

### HSRP

| Task | Command |
|---|---|
| State / who's Active | `show standby brief` |
| Detail (peer, timers, vMAC) | `show standby` |
| L2/L3 path test between routers | `ping 192.168.10.3` (peer's **real** IP) |

### OSPF

| Task | Command |
|---|---|
| Neighbors (want `FULL`) | `show ip ospf neighbor` |
| Advertised networks / router-id | `show ip protocols` |
| Per-interface (area, cost, timers) | `show ip ospf interface brief` |
| Routes learned | `show ip route ospf` |
| Apply a config / router-id change | `clear ip ospf process` |

### NAT

| Task | Command |
|---|---|
| Translation table | `show ip nat translations` |
| Hits + inside/outside interfaces | `show ip nat statistics` |
| NAT lines from config | `show run | section nat` |
| Clear translations | `clear ip nat translation *` |

### ACL

| Task | Command |
|---|---|
| Rules + hit counters | `show access-lists` |
| ACL on interface + direction | `show ip interface GigabitEthernet0/0.10` |
| Clear counters | `clear access-list counters` |

### General

| Task | Command |
|---|---|
| Interface up? IP assigned? | `show ip interface brief` |
| Full config of one subinterface | `show running-config interface GigabitEthernet0/0.10` |
| Save config | `write memory` (`wr`) |

---

## 6. How the topics connect

> [!note]
> - **[[01 - Layer 2 foundation]]** underpins everything: an empty `show standby brief` /
>   `show ip nat translations` / `show ip ospf neighbor` usually means a trunk or
>   subinterface problem, not the protocol.
> - **[[02 - HSRP]] ↔ [[03 - OSPF]]**: HSRP picks the Active gateway; OSPF gives it a real
>   upstream path. Configure and test them together (fail the Active's uplink, watch Standby
>   take over).
> - **[[05 - ACL]] ↔ [[04 - NAT and PAT]]**: the NAT selection list is a standard ACL; `/27`
>   LANs use wildcard `0.0.0.31`.
