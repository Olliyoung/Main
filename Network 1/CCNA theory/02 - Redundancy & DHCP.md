---
tags: [network-1, ccna, srwe, theory, fhrp, hsrp, glbp, dhcp, dhcpv6, slaac]
aliases: ["HSRP", "GLBP", "FHRP", "DORA", "SLAAC", "DAD"]
---

# 02 — First-hop redundancy & DHCP

> [!info] Related
> HSRP config for the Network 2 lab is in [[02 - HSRP]]. This is the checkpoint‑exam theory.

## First Hop Redundancy Protocols (FHRP)

| Protocol | Vendor | Redundancy | Load balancing |
|---|---|---|---|
| **HSRP** | Cisco proprietary | yes (Active + Standby) | no (by default) |
| **GLBP** | Cisco proprietary | yes | **yes** — traffic spread across routers via different virtual MACs |
| VRRP | open standard | yes | no |

### HSRP essentials

- One **Active** router forwards; one **Standby** waits.
- Hosts use the **virtual IP** as their default gateway — never a physical router IP.
- Highest **priority** wins (default 100); tie → highest real IP.
- `preempt` lets a higher‑priority router reclaim Active after it recovers.

### HSRP failover sequence

1. The Active (forwarding) router fails.
2. The Standby stops receiving Hello messages.
3. The Standby becomes the new forwarding router.
4. It assumes the **virtual IP + virtual MAC** → hosts see no change.

> [!tip] Troubleshooting reflex
> If gateway redundancy "doesn't work", first check the hosts are pointed at the **virtual
> IP**, not a physical router address.

## DHCPv4 — DORA

1. **DISCOVER** — client broadcasts, looking for servers
2. **OFFER** — server offers an address
3. **REQUEST** — client requests the offered address
4. **ACK** — server confirms the lease

| Command | Shows / does |
|---|---|
| `show ip dhcp binding` | addresses currently leased to clients |
| `ip address dhcp` | makes a router interface a DHCP **client** |
| `ip helper-address` | makes the router a DHCP **relay agent** (also relays other UDP services) |

- **Pool calc example:** `192.168.234.0/27` → 32 total, 30 usable; reserve 22 for phones →
  **8 left** for other hosts.
- **DHCP starvation:** attacker floods DISCOVERs with fake MACs, drains the pool → legit
  clients get nothing. Mitigate with **port security** + **DHCP snooping**.
- **DHCP snooping:** only ports toward a legitimate server (or the path to it) are **trusted**;
  client‑facing ports stay untrusted.

## IPv6 addressing

| Method | Address from | Extra config (DNS etc.) |
|---|---|---|
| Pure SLAAC | SLAAC | RA options |
| Stateless DHCPv6 | SLAAC | DHCPv6 |
| Stateful DHCPv6 | DHCPv6 | DHCPv6 |

**Router Advertisement flags**
- **M‑flag** (Managed) → use stateful DHCPv6 for the address
- **O‑flag** (Other) → use DHCPv6 for other info only

### Duplicate Address Detection (DAD)

1. New address starts as **Tentative**.
2. Host sends an **ICMPv6 Neighbor Solicitation** for it.
3. No **Neighbor Advertisement** comes back → address is unique → becomes usable.

## Memory aids

- **HSRP** = Active + Standby, no load balancing by default
- **GLBP** = load balancing + redundancy
- **DORA** = Discover → Offer → Request → Ack
- **DAD** = Neighbor Solicitation → no NA = unique
