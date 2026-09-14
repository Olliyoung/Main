---
tags: [network-1, ccna, srwe, theory, routing, static-routing, administrative-distance]
aliases: ["Administrative distance", "Static vs dynamic", "Route types"]
---

# 01 — Routing & static routes

> [!info] Source
> Merged from the two CCNA checkpoint note files + the static routing notes. Config commands
> live in [[05 - Static routing & management]].

## Static vs dynamic routing

| Use **static** when… | Use **dynamic** when… |
|---|---|
| Stub network with a single exit point | Network has many topology changes |
| Small network that will not grow | Network will expand |
| You want minimal router CPU/RAM use | You can spend resources for automatic reconvergence |
| You want it not advertised (slightly more secure) | Manual upkeep would not scale |

- Static needs **good** knowledge of the whole topology.
- Static does not scale and is error‑prone on large networks.

## Administrative distance (AD)

Lower AD = more trusted. The router installs the route with the **lowest AD** into the table.

| Source | Code | AD |
|---|---|---|
| Connected | `C` | 0 |
| Static | `S` | 1 |
| EIGRP internal | `D` | 90 |
| OSPF | `O` | 110 |
| RIP / RIPng | `R` | 120 |
| EIGRP external | `D EX` | 170 |

### Reading the table

- Format is always `[AD/metric]` — e.g. `R 2001:DB8:CAFE:4::/64 [120/4]` → AD 120, metric 4.
- Letter codes: `C` connected · `L` local · `S` static · `O` OSPF · `R` RIP.

## Types of static route

> [!example] Default route (catches everything else)
> - IPv4: `ip route 0.0.0.0 0.0.0.0 <next-hop>`
> - IPv6: `ipv6 route ::/0 <next-hop>`
> - **Not** `::/128` (single host), **not** `::1/64`, **not** `FFFF::/128`.

> [!example] Floating static (backup)
> - Same destination as a dynamic route, but **higher AD** than that protocol (e.g. 95 or 210).
> - Sleeps until the dynamic route disappears.
> - AD `1` is **not** floating — it beats EIGRP/OSPF and becomes primary.

> [!example] Fully specified static
> - Gives **both** exit interface **and** next‑hop: `ip route 0.0.0.0 0.0.0.0 Fa0/0 10.1.1.1`.
> - Use on multiaccess Ethernet to avoid proxy‑ARP and recursive lookups.
> - Interface‑only on Ethernet → ARP for every destination (bad). Next‑hop‑only → extra
>   recursive lookup.

> [!example] Summary static
> - One prefix that covers many networks.

## Static route behaviour

- **Cannot edit** a static route — `no ip route …` the old one, then add the new one.
- **Exit interface goes down** → the config line stays, the route is **removed** from the
  table, and the router does **not** invent a new path or poll neighbours.

> [!warning] Classic exam mistakes
> - Network address used as the next‑hop (e.g. `172.16.2.0`) → route never installs.
> - Using the neighbour's interface instead of your own.
> - Floating static with AD **lower** than the dynamic protocol → it takes over and stays.
> - Missing the **return** route on the other side → one‑way traffic.
> - Forgetting `ipv6 unicast-routing` before IPv6 statics.

## Packet fields leaving a PC

- **Destination IP** = the final server — never changes hop to hop.
- **Destination MAC** = this hop's default gateway — changes at every hop.
- **Source IP** = the PC itself.

## Memory box

- AD: Connected 0 → Static 1 → EIGRP 90 → OSPF 110 → RIP 120
- Default prefix: `0.0.0.0/0` or `::/0`
- Floating = higher AD than the protocol
- Fully specified = interface + next‑hop
- Interface down → route leaves the table
- Change next‑hop → `no` + re‑add
