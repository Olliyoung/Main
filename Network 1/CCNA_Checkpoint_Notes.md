
Routing · AD · Static routes · WLAN / Security

---

# Static vs Dynamic Routing

## When to use which

* Use **static** on a stub network with a single exit point
* Use **static** on a small network that will not grow
* Use **dynamic** on a network with many topology changes
* Use **dynamic** when the network will expand
* Static uses fewer router resources than dynamic
* Static is more secure because it does not advertise over the network
* Static requires good knowledge of the network (not little knowledge)
* Static does not scale well and is not easy for large networks

---

# Administrative Distance

Lower AD = more trusted. Router installs the lowest AD into the table.

| Source | Code | AD |
|---|---|---|
| Connected | C | 0 |
| Static | S | 1 |
| EIGRP internal | D | 90 |
| OSPF | O | 110 |
| RIP / RIPng | R | 120 |
| EIGRP external | D EX | 170 |

## Reading the table

* Format is always `[AD/metric]`
* Example: `R  2001:DB8:CAFE:4::/64 [120/4]` → AD = **120**, metric = 4
* Letter codes: `C` connected · `L` local · `S` static · `O` OSPF · `R` RIP

---

# Types of Static Routes

## Default route (matches all leftover packets)

* IPv4 default <ip route 0.0.0.0 0.0.0.0 next-hop>
* IPv6 default <ipv6 route ::/0 next-hop>
* **Not** `::/128` (that is a single host)
* **Not** `::1/64` or `FFFF::/128`

## Floating static (backup)

* Same destination as a dynamic route
* **Higher AD** than the protocol (e.g. 95 or 210 vs EIGRP 90)
* Sleeps until the dynamic route is gone
* AD **1** is **not** floating — it beats EIGRP/OSPF and becomes primary

## Fully specified static

* Gives **both** exit interface **and** next-hop
* Example <ip route 0.0.0.0 0.0.0.0 FastEthernet0/0 10.1.1.1 95>
* Use on multiaccess Ethernet to avoid proxy-ARP and recursive lookups
* Interface-only on Ethernet → ARP for every destination (bad)
* Next-hop-only → extra recursive lookup

## Summary static

* One prefix that covers many networks

---

# Static Route Commands

## Basic structure

- Create a static route <ip route destination-network subnet-mask next-hop>
- Optional AD at the end <ip route destination-network subnet-mask next-hop AD>The number at the end is **administrative distance**, not metric or hop count


 
 ## Example to LAN C via neighbor B

* On router A <ip route 192.168.4.0 255.255.255.0 192.168.3.2>
* Dest = remote network · Next-hop = neighbor you can already reach

## Change next-hop of an existing static

* Cannot edit — delete then re-add
* Remove old <no ip route 10.0.0.0 255.0.0.0 172.16.40.2>
* Add new <ip route 10.0.0.0 255.0.0.0 192.168.1.2>

## When exit interface goes down

* Config line **stays**
* Route is **removed** from the routing table
* Router does **not** invent a new path or poll neighbors

---

# Packet Fields Leaving a PC

* Dest **IP** = final server (never changes hop to hop)
* Dest **MAC** = default gateway on this LAN (changes every hop)
* Src IP = the PC itself

---

# Port Security

* Enable port security <switchport port-security>
* Max MAC addresses <switchport port-security maximum 2>
* Violation mode (default is shutdown) <switchport port-security violation shutdown>
* Sticky learning <switchport port-security mac-address sticky>
* Show status <show port-security>
* Show interface detail <show port-security interface FastEthernet0/1>
* Show secure MACs <show port-security address>

## Recover err-disabled port

* Enter interface <interface FastEthernet0/1>
* Bounce it <shutdown>
* Bring it back <no shutdown>

---

# VLAN Hopping Mitigations

* Disable DTP <switchport nonegotiate>
* Force trunk manually <switchport mode trunk>
* Change native VLAN to an unused VLAN <switchport trunk native vlan X>

---

# BPDU Guard

* On PortFast access ports — BPDU arrives → err-disable
* Blocks rogue switches
* Enable <spanning-tree portfast bpduguard enable>
* Remove <no spanning-tree portfast bpduguard enable>
* Check err-disabled <show errdisable recovery>
* Check interface <show interfaces status>

---

# DHCP Snooping & Starvation

* Starvation = attacker floods DHCP discovers and empties the pool
* Mitigate with **port security** + **DHCP snooping**
* Rate limit <ip dhcp snooping limit rate N>
* Exceeding the rate → err-disable

---

# AAA / Authentication

* WLAN username + password verified by a server → **RADIUS**
* AAA is the framework; RADIUS is the actual server protocol
* Authentication = who you are (usernames and passwords)
* Authorization = what you can do
* Accounting = what you did (logs)
* 802.1X is a method that *uses* authentication; it is not “the component based on user/pass”

---

# Wireless Quick Facts

* CAPWAP tunnel between lightweight AP and WLC (UDP 5246 / 5247)
* 2.4 GHz non-overlapping channels: **1, 6, 11**
* Mixed b/g + new dual-band AP → split traffic: old clients on 2.4, capable on 5 GHz
* Microwave ovens → accidental 2.4 GHz interference
* Home AP best practice: change default SSID, admin password, wireless passphrase

---

# IPv6 Route Codes

* `C` connected — AD 0
* `L` local address — AD 0
* `S` static — AD 1
* `O` OSPF — AD 110
* `R` RIP — AD 120
* Default route prefix <::/0>

---

# Memory Box

* AD: Connected 0 → Static 1 → EIGRP 90 → OSPF 110 → RIP 120
* Default: `0.0.0.0/0` or `::/0`
* Floating = higher AD than protocol
* Fully specified = interface + next-hop
* Interface down → route leaves table
* Change next-hop → `no` + re-add
* Dest IP stays end host · Dest MAC = this hop’s gateway

