---
tags: [network-1, cisco, packet-tracer, cheat-sheet, ccna, srwe]
aliases: ["Cisco cheat sheet", "IOS abbreviations", "show commands"]
---

# 00 — Cheat sheet (abbreviations · show · testing)

> [!info] What this folder is
> Merged, de‑duplicated command reference for Network 1 / CCNA SRWE, split by topic and
> numbered in roughly the order you configure a device. Every block is copy‑paste ready;
> `!` comment lines are safe to paste.
>
> **Files:** [[01 - Device setup & SSH]] · [[02 - Switching]] · [[03 - Inter-VLAN routing & DHCP]] ·
> [[04 - Security]] · [[05 - Static routing & management]]

## Abbreviations that actually save time in Packet Tracer

| Short | Full |
|---|---|
| `conf t` | `configure terminal` |
| `int fa0/1` | `interface FastEthernet0/1` |
| `int gi0/1` | `interface GigabitEthernet0/1` |
| `int range fa0/1-10` | `interface range FastEthernet0/1-10` |
| `ex` | `exit` |
| `no shut` | `no shutdown` |
| `shut` | `shutdown` |
| `sw` | `switchport` |
| `sw mode acc` | `switchport mode access` |
| `sw mode trunk` | `switchport mode trunk` |
| `sw acc vlan 10` | `switchport access vlan 10` |
| `enc dot1q 10` | `encapsulation dot1Q 10` |
| `ip add <ip> <mask>` | `ip address <ip> <mask>` |
| `wr` | `write memory` (save running → startup) |
| `end` | jump straight back to privileged EXEC |

## Show / verification commands

| Command | Shows |
|---|---|
| `show running-config` | full live config |
| `show running-config interface Gi0/1.20` | just one interface / subinterface |
| `show ip interface brief` | every interface: IP + up/down status |
| `show vlan brief` | VLANs and which access ports are in them |
| `show interfaces trunk` | trunk ports, native VLAN, allowed + active VLANs |
| `show interfaces status` | port status (connected / notconnect / err-disabled) |
| `show mac address-table` | learned MACs per port |
| `show etherchannel summary` | port-channel status and member ports |
| `show spanning-tree` / `show spanning-tree vlan 10` | root bridge, port roles/states |
| `show port-security` / `show port-security interface Fa0/1` | port-security status + violations |
| `show errdisable recovery` | which features auto‑recover err‑disabled ports, and timer |
| `show ip ssh` | SSH version and settings |
| `show ip route` | routing table |

## Testing

| Command | Use |
|---|---|
| `ping <ip>` | basic reachability |
| `traceroute <ip>` | hop‑by‑hop path |
| `wr` | save before you close the lab |

> [!tip] Reading a routing table line
> Format is always `[AD/metric]`. Letter codes: `C` connected · `L` local · `S` static ·
> `O` OSPF · `R` RIP. Lower administrative distance wins. See
> [[01 - Routing & static routes]] in the CCNA theory folder.
