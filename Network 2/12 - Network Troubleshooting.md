---
tags: [network-2, ensa, theory, troubleshooting, documentation, osi-layers]
aliases: ["Troubleshooting Process", "Network Documentation", "Module 12"]
---

# 12 — Network Troubleshooting

> ENSA Module 12 notes: documentation, the troubleshooting process, symptoms/causes per OSI
> layer, and the full end-to-end connectivity walkthrough (with the worked examples from the
> course, addresses kept as given). See also [[01 - Layer 2 foundation]],
> [[03 - OSPF]], [[04 - NAT and PAT]], [[05 - ACL]] for the config side of these problems.

## Contents

- [[#12.1 Network Documentation]]
- [[#12.2 Troubleshooting Process]]
- [[#12.4 Symptoms and Causes of Network Problems]]
- [[#12.5 Troubleshooting IP Connectivity]]

---

## 12.1 Network Documentation

### Network topology diagrams

Two types, tracking location/function/status of devices:

> [!info] Physical topology
> Shows the **physical layout** of connected devices — needed to troubleshoot physical
> layer problems. Records: device name, device location (address/room/rack), interfaces and
> ports used, cable type.
>
> Example: a Central router (Building A, Rm 107) with Metro Ethernet to the ISP, a
> redundant serial link to Branch-2, and a link to Branch-1 (Building B) — each site's
> interfaces, rack/shelf, and cable labeled down to the access switches and PCs.

> [!info] Logical topology
> Shows how devices are **logically connected** — how data actually flows, using symbols for
> routers/switches/servers/hosts. Connections between sites may be shown without matching
> physical locations. Records: device identifiers, IP addresses + prefix lengths, interface
> identifiers, routing protocols/static routes, Layer 2 info (VLANs, trunks, EtherChannels).
> IPv6 is normally drawn as a **separate** logical topology from IPv4 for clarity.
>
> Example (IPv4): Central ↔ Svr1 (10.0.0.0/30), Central ↔ ISP (209.165.200.224/30) ↔ Svr2,
> Central ↔ Branch-1 (10.1.1.0/30), Branch-1 ↔ Branch-2 (redundant serial). Branch-1's
> switches carry a VLAN table (10 = LAN-1, 20 = LAN-2, 77 = Management, 99 = Native,
> 999 = Unused) over a trunk + a Port-channel (Po1) between S1 and S2.

### Network device documentation

Accurate, up-to-date records of hardware/software — usually kept as tables or spreadsheets.

**Router documentation** (per device: model, description, location, IOS, license; per
interface: description, IPv4/IPv6 address, MAC, routing protocol):

| Device | Model | Description | Location | IOS | License |
|---|---|---|---|---|---|
| Central | ISR 4321 | Central Edge Router | Building A Rm 137 | IOS XE 16.09.04 | ipbasek9, securityk9 |
| Branch-1 | ISR 4221 | Branch-2 Edge Router | Building B Rm 107 | IOS XE 16.09.04 | ipbasek9, securityk9 |

| Interface | Description | IPv4 | IPv6 | Routing |
|---|---|---|---|---|
| Central G0/0/0 | Connects to SVR-1 | 10.0.0.1/30 | 2001:db8:acad:1::1/64 | OSPF |
| Central G0/0/1 | Connects to Branch-1 | 10.1.1.1/30 | 2001:db8:acad:a001::1/64 | OSPFv3 |
| Central G0/1/0 | Connects to ISP | 209.165.200.226/30 | 2001:db8:feed:1::2/64 | Default |
| Central S0/1/1 | Connects to Branch-2 | 10.1.1.2/24 | n/a | OSPFv3 |
| Branch-1 G0/0/0 | Connects to S1 | Router-on-a-stick | Router-on-a-stick | OSPF |
| Branch-1 G0/0/1 | Connects to Central | 10.1.1.2/30 | 2001:db8:acad:a001::2/64 | OSPF |

**LAN switch documentation** (device: model, description, mgmt IP, IOS, VTP; per port:
description, access/VLAN, trunk, EtherChannel, native VLAN, enabled):

| Device | Model | Mgmt IP | IOS | VTP |
|---|---|---|---|---|
| S1 | Catalyst WS-C2960-24TC-L | 192.168.77.2/24 | 15.0(2)SE7 | Domain CCNA, Mode Server |

| Port | Description | Access | VLAN | Trunk | EtherChannel | Native | Enabled |
|---|---|---|---|---|---|---|---|
| Fa0/1 | Po1 trunk to S2 Fa0/1 | — | — | Yes | Port-Channel 1 | 99 | Yes |
| Fa0/2 | Po1 trunk to S2 Fa0/2 | — | — | Yes | Port-Channel 1 | 99 | Yes |
| Fa0/3 | Not in use | Yes | 999 | — | — | — | Shut |
| Fa0/5 | Access port to user | Yes | 10 | — | — | — | Yes |
| Fa0/24 | Not in use | Yes | 999 | — | — | — | Shut |
| G0/1 | Trunk link to Branch-1 | — | — | Yes | — | 99 | Yes |

---

## 12.2 Troubleshooting Process

### General troubleshooting procedures

Structured methods shorten troubleshooting time versus erratic hit-and-miss guessing — but
they aren't rigid; steps aren't always executed in the same order. A simplified flow:

```
Stage 1: Gather Symptoms
Stage 2: Isolate the Problem
Stage 3: Implement Corrective Action
→ Problem fixed?
    No  → undo the corrective action, go back to Stage 1
    Yes → Stage 4: Document solution and save changes
```

### The seven-step troubleshooting process

More detailed, with steps that interconnect (experienced techs may jump between them):

1. **Define Problem**
2. **Gather Information** ↔ **Analyze Information** (these two feed each other)
3. **Eliminate Possible Causes**
4. **Propose Hypothesis**
5. **Test Hypothesis**
6. **Solve the Problem and Document Solution**

### Question end users

Most problems are first reported vaguely ("the network is down", "my computer is slow").
Guidelines when interviewing the user:
- Speak at their technical level, avoid jargon.
- Listen/read carefully; take notes on complex problems.
- Be considerate, empathize — users reporting a problem may be stressed.
- Use **open questions** (need a detailed answer) and **closed questions** (yes/no/one word)
  to zero in on facts.
- Repeat your understanding of the problem back to the user before moving on.

| Guideline | Example questions |
|---|---|
| Ask pertinent questions | What does not work? What exactly is the problem? What are you trying to accomplish? |
| Determine scope | Who does this affect — just you or others? What device is this on? |
| Determine when it occurs | When exactly? When first noticed? Any error messages? |
| Constant or intermittent? | Can you reproduce it? Can you send a screenshot/video? |
| Determine what changed | What has changed since it last worked? |
| Eliminate/discover causes | What works? What doesn't? |

### Gather information

Use IOS commands + tools like packet captures and device logs:

| Command | Description |
|---|---|
| `ping {host \| ip-address}` | Echo request, waits for reply |
| `traceroute destination` | Identifies the path a packet takes through the network |
| `telnet {host \| ip-address}` | Connect via Telnet — prefer SSH |
| `ssh -l user-id ip-address` | Connect via SSH (more secure than Telnet) |
| `show ip interface brief` / `show ipv6 interface brief` | Summary status + IP of every interface |
| `show ip route` / `show ipv6 route` | Current routing table |
| `show protocols` | Configured protocols + global/interface L3 status |
| `debug` | List of debugging-event options |

> [!warning] `debug` caution
> `debug` generates a lot of console traffic and can noticeably affect device performance.
> If it must run during work hours, warn users first, and remember to **disable it** when
> done.

### Troubleshooting with layered models

The OSI/TCP-IP models help isolate problems — e.g. symptoms pointing at a physical
connection mean focus on Layer 1. Devices map to layers up to where they operate: end
system → up through Application (7); router/multilayer switch → shown at Transport (4),
since ACLs on them can filter using Layer 4 info even though forwarding decisions are L3;
standard switch → Data Link (2); cabling/ports/interfaces → Physical (1).

| Method | How it works | Best for | Downside |
|---|---|---|---|
| **Bottom-Up** | Start at Physical, move up until the cause is found | Suspected physical problem — most problems live at the lower layers | Must check every device/interface until found; lots of documentation |
| **Top-Down** | Start at Application, move down | Simpler problems, or a suspected software issue | Must check every application until found |
| **Divide-and-Conquer** | Pick a layer, test in both directions from it (verified working layer ⇒ layers below it are fine) | When you can make an informed guess which layer to start at | Needs a solid initial guess |
| **Follow-the-Path** | Discover the actual traffic path source→destination first, scope troubleshooting to just the links/devices in that path | Reducing scope before applying another method | Complements another method, not standalone |
| **Substitution** | Swap the suspect device for a known-good one | Quick resolution of a critical single point of failure (e.g. a dead border router) | Doesn't isolate the root cause; useless if the fault spans multiple devices |

### Guidelines for selecting a troubleshooting method

| Type of problem | Recommended method |
|---|---|
| Software-oriented | Top-Down |
| Hardware/cable-oriented, or complex | Bottom-Up |
| New problem, handled by an experienced tech | Divide-and-Conquer |
| (otherwise) | Bottom-Up |

Troubleshooting is a skill built by doing it — every problem solved adds to your skill set.

---

## 12.4 Symptoms and Causes of Network Problems

### Physical layer troubleshooting

Physical-layer failures inconvenience users and can hit company-wide productivity —
networks in this state usually just stop working. The upper layers all depend on Layer 1.

| Symptom | Notes |
|---|---|
| Performance lower than baseline | Needs a previous baseline to compare against; common causes: overloaded/underpowered servers, unsuitable switch/router config, congestion on a low-capacity link, chronic frame loss |
| Loss of connectivity | Failed/disconnected cable; verify with a simple ping; **intermittent** loss can mean a loose or oxidized connection |
| Network bottlenecks/congestion | A failed router/interface/cable can make routing protocols redirect traffic onto routes not sized for the extra load |
| High CPU utilization | Device (router/switch/server) operating at/beyond design limits; unaddressed → shutdown/failure |
| Console error messages | May indicate a physical problem — log console messages to a central syslog server |

| Cause | Notes |
|---|---|
| Power-related | Most fundamental failure cause. Check fans, chassis intake/exhaust vents; if nearby units also lost power, suspect the main supply |
| Hardware faults | Faulty NICs → late collisions, short frames, **jabber** (device continually transmits random meaningless data) — caused by bad/corrupt NIC drivers, bad cabling, grounding problems |
| Cabling faults | Reseating a partially disconnected cable fixes many issues; inspect for damage, wrong cable type, poorly crimped RJ-45; test/swap suspect cables |
| Attenuation | Cable exceeds the media's design length, or a loose/dirty/oxidized connection; severe attenuation → receiver can't distinguish bits |
| Noise (EMI) | From FM radio, police radio, building security, avionics, crosstalk from nearby cables, electric motors, or anything transmitting stronger than a cell phone |
| Interface configuration errors | Wrong clock rate/source, interface not turned on → loss of connectivity with attached segments |
| Exceeding design limits | Component used beyond spec/configured capacity → rising interface errors |
| CPU overload | High CPU %, input queue drops, slow performance, SNMP timeouts, DHCP/Telnet/ping slow or failing; on switches: STP reconvergence, EtherChannel bouncing, UDLD flapping, IP SLA failures; on routers: no routing updates, route flapping, HSRP flapping. Often caused by high traffic — consider redesigning traffic flow or upgrading hardware |

### Data link layer troubleshooting

L2 protocol config/operation is critical to a well-tuned network — recognizable symptoms
help identify the problem fast.

| Symptom | Notes |
|---|---|
| No functionality/connectivity at network layer+ | Some L2 problems stop frame exchange entirely; others just degrade performance |
| Below-baseline performance | Two flavors: (1) frames take a suboptimal path but arrive → unexpected high bandwidth usage; (2) frames dropped, seen via error counters/console messages — an extended/continuous ping can reveal drops |
| Excessive broadcasts | OSes use broadcast/multicast heavily to discover services/hosts; excessive amounts usually mean a poorly configured app, a large L2 broadcast domain, or an underlying issue (STP loops, route flapping) |
| Console messages | A router alerts the console when it detects an L2 problem (interpreting incoming frames) or missing expected keepalives — most common: a **line protocol down** message |

| Cause | Notes |
|---|---|
| Encapsulation errors | Sender put bits in a field the receiver doesn't expect — e.g. mismatched encapsulation configured on the two ends of a WAN link |
| Address mapping errors | On point-to-multipoint/broadcast Ethernet, the device must map a destination L3 address to the right L2 address (static or dynamic). Fails if a device is configured not to answer ARP, cached L2/L3 info changed physically, or invalid ARP replies arrive (misconfig or attack) |
| Framing errors | Frames work in groups of 8-bit bytes; a framing error = frame doesn't end on an 8-bit boundary → receiver can't tell where one frame ends and the next starts; too many invalid frames can block valid keepalives. Caused by a noisy serial line, a bad/unshielded/too-long cable, faulty NIC, duplex mismatch, or misconfigured CSU line clock |
| STP failures or loops | STP resolves a redundant physical topology into a loop-free tree by blocking ports. Most STP problems are forwarding loops (no port blocked in a redundant topology → traffic forwarded in circles, excessive flooding from a high rate of topology changes). A topology change should be rare in a well-configured network; a **flapping** port (up/down oscillation) causes repeated changes and flooding/slow (re)convergence. Causes: mismatch between real and documented topology, config error (inconsistent STP timers), overloaded switch CPU during convergence, or a software defect |

### Network layer troubleshooting

Covers any problem involving a Layer 3 protocol — IPv4, IPv6, EIGRP, OSPF, etc.

| Symptom | Notes |
|---|---|
| Network failure | Network nearly/completely non-functional, affects all users/apps — noticed quickly, obviously critical |
| Suboptimal performance | Usually hits a subset of users/apps/destinations/traffic type; hard to detect and isolate since it can involve multiple layers or a single host; takes time to even confirm it's a Layer 3 problem |

Static routes mixed with dynamic protocols can misconfigure into suboptimal routing or even
**routing loops** that make parts of the network unreachable. There's no single template for
Layer 3 problems — solve methodically with a series of commands to isolate and diagnose:

| Area to check | What to look for |
|---|---|
| General network issues | Any recent topology change (e.g. a down link) can affect other areas non-obviously; installed/removed routes (static or dynamic); has anyone recently worked on the infrastructure? |
| Connectivity issues | Equipment/connectivity problems: power outages, environmental issues (overheating); Layer 1 issues: cabling, bad ports, ISP problems |
| Routing table | Anything unexpected — missing or unexpected routes; use `debug` to watch routing updates and table maintenance |
| Neighbor issues | If the protocol forms neighbor adjacencies, check for problems forming them |
| Topology database | If the protocol keeps a topology table/database, check for missing/unexpected entries |

### Transport layer troubleshooting — ACLs

ACLs and NAT both operate at the network layer but can involve Layer 4 operations, so
transport-layer problems often show up at the network edge where traffic is inspected and
modified.

| Symptom | Cause |
|---|---|
| Connectivity issues / access issues | ACL misconfiguration, NAT misconfiguration |

Common ACL misconfigurations:

| Misconfiguration | Notes |
|---|---|
| Selection of traffic flow | Traffic is defined by both the interface it's traveling through and the direction — the ACL must be on the right interface, in the right direction |
| Order of ACEs | Entries should go specific → general; a later, more-specific `permit` never matches if an earlier entry already denies that traffic. If both ACLs and NAT run on a router, their **order matters**: inbound traffic hits the inbound ACL **before** outside-to-inside NAT; outbound traffic hits the outbound ACL **after** inside-to-outside NAT (see [[04 - NAT and PAT]]) |
| Implicit deny any | Can be the cause of a misconfig when high security isn't actually required |
| Addresses and IPv4 wildcard masks | Complex wildcard masks improve efficiency but are more error-prone — e.g. `10.0.32.0` with wildcard `0.0.32.15` selects the first 15 host addresses in **either** `10.0.0.0` or `10.0.32.0` |
| Selection of transport layer protocol | Must specify the correct protocol; when unsure whether traffic uses TCP or UDP, admins sometimes configure **both** — this opens an extra hole in the firewall (possible intrusion path) and adds latency (more ACEs to process) |
| Source and destination ports | Properly controlling traffic between two hosts needs **symmetric** ACEs for inbound and outbound — a replying host's address/port info mirrors the initiating host's |
| Use of the `established` keyword | Increases the security an ACL provides, but applied incorrectly can cause unexpected results |
| Uncommon protocols | Misconfigured ACLs often break protocols other than TCP/UDP — an increasingly common example: VPN and encryption protocols |

> [!tip] The `log` keyword
> Instructs the router to log an entry whenever that ACE matches — useful for troubleshooting
> and for seeing intrusion attempts the ACL blocked.

### Transport layer troubleshooting — NAT for IPv4

NAT problems often come from interoperability with services/protocols that carry or derive
info from host addressing inside the packet — NAT can't rewrite addressing info buried in
the payload.

| Protocol | Interoperability issue |
|---|---|
| BOOTP and DHCP | Both auto-assign IPv4 addresses. The client's first packet (DHCP-Request) is a broadcast with **source `0.0.0.0`** — since NAT needs a valid source *and* destination address, BOOTP/DHCP struggle over a router running static or dynamic NAT. `ip helper-address` can help. |
| DNS | A router running **dynamic** NAT keeps changing inside↔outside address mappings as table entries expire/recreate, so a DNS server outside the NAT router can't hold an accurate view of the inside network. `ip helper-address` can help. |
| SNMP | Like DNS, NAT can't alter addressing info stored in the packet **payload** — an SNMP manager on one side of a NAT router may not be able to reach agents on the other side. `ip helper-address` can help. |
| Tunneling / encryption protocols | Often require traffic sourced from a specific UDP/TCP port, or use a transport-layer protocol NAT can't process — e.g. IPsec tunneling and GRE used by VPNs (see [[07 - IPsec framework]]) can't be processed by NAT. |

### Application layer troubleshooting

Application protocols provide user services — network management, file transfer,
distributed file services, terminal emulation, email, and newer ones like VPNs and VoIP.

| OSI | TCP/IP | Protocols |
|---|---|---|
| 7 Application / 6 Presentation / 5 Session | Application | HTTP, Telnet, FTP, TFTP, SMTP, POP, IMAP, SNMP, NTP, DNS, NNTP · plus NFS, XDR, RPC |
| 4 Transport | Transport | TCP, UDP |
| 3 Network | Internet | Routing protocols, IP, ICMP |
| 2 Data Link / 1 Physical | Network | ARP, ND · (not specified) |

| Protocol | Description |
|---|---|
| SSH/Telnet | Establish terminal session connections with remote hosts |
| HTTP | Exchange of text, images, sound, video, and other multimedia on the web |
| FTP | Interactive file transfers between hosts |
| TFTP | Basic interactive file transfers, typically between hosts and network devices |
| SMTP | Basic message delivery services |
| POP | Connect to mail servers and download email |
| SNMP | Collects management information from network devices |
| DNS | Maps IP addresses to device names |
| NFS | Mount and operate remote drives as if local (with XDR + RPC) |

- A problem here can make resources **unreachable/unusable even though L1–L4 are all
  functional** — full connectivity exists, but the app just doesn't deliver data.
- Or L1–L4 are fine but a single service/app doesn't meet normal user expectations (e.g.
  it's sluggish transferring data or requesting services).

---

## 12.5 Troubleshooting IP Connectivity

> Worked scenario used throughout this section: **PC1 cannot reach applications on SRV1 or
> SRV2.** PC1 uses SLAAC + EUI-64 for its IPv6 address (EUI-64 builds the interface ID from
> the MAC, inserting `FFFE` in the middle and flipping the 7th bit).

### Reference topology

| Device | Interface | IPv4 | IPv6 | Notes |
|---|---|---|---|---|
| R1 | S0/1/0 | 192.168.1.1/30 | 2001:db8:acad:2::1/64 | to R2 |
| R1 | G0/0/0 | 10.1.10.1/24 | 2001:db8:acad:1::1/64 | LAN (S1/S2, PC1, SRV2) |
| R2 | S0/1/0 | 192.168.1.2/30 | 2001:db8:acad:2::2/64 | to R1 |
| R2 | S0/1/1 | 192.168.1.5/30 | 2001:db8:acad:3::1/64 | to R3 |
| R3 | S0/1/1 | 192.168.1.6/30 | 2001:db8:acad:3::2/64 | to R2 |
| R3 | G0/0/0 | 172.16.1.1/24 | 2001:db8:acad:4::1/64 | LAN (S3, SRV1) |
| PC1 | NIC | 10.1.10.10/24 | 2001:db8:acad:1:5075:d0ff:fe8e:9ad8/64 | MAC `5475.D08E.9AD8` |
| SRV2 | NIC | 10.1.10.100/24 | 2001:db8:acad:1::100/64 | on R1's LAN |
| SRV1 | NIC | 172.16.1.100/24 | 2001:db8:acad:4::100/64 | on R3's LAN |

### The bottom-up troubleshooting steps for end-to-end connectivity

When there's no end-to-end connectivity and the admin picks a bottom-up approach:

1. **Check physical connectivity** at the point communication stops (cables/hardware — a
   faulty cable/interface, or misconfigured/faulty hardware).
2. **Check for duplex mismatches.**
3. **Check data link and network layer addressing** on the local network — IPv4 ARP
   tables, IPv6 neighbor tables, MAC address tables, VLAN assignments.
4. **Verify the default gateway is correct.**
5. **Ensure devices determine the correct path** source→destination; manipulate routing
   info if needed.
6. **Verify the transport layer is functioning** — Telnet can test transport-layer
   connections from the CLI.
7. **Verify no ACLs are blocking traffic.**
8. **Ensure DNS settings are correct** — a DNS server must be reachable.

Outcome: operational end-to-end connectivity. If all 8 steps run with no fix, repeat them or
escalate to a senior admin.

### What kicks off troubleshooting: ping and traceroute

`ping` and `traceroute` are the two most common tools for confirming an end-to-end problem.

> [!example] `ping` (IPv4/IPv6)
> Uses ICMP echo request/reply. Works for both IPv4 and IPv6.
> ```
> C:\> ping 172.16.1.100
> Pinging 172.16.1.100 with 32 bytes of data:
> Reply from 172.16.1.100: bytes=32 time=199ms TTL=128
> Reply from 172.16.1.100: bytes=32 time=193ms TTL=128
> Reply from 172.16.1.100: bytes=32 time=194ms TTL=128
> Reply from 172.16.1.100: bytes=32 time=196ms TTL=128
> Ping statistics for 172.16.1.100:
>     Packets: Sent = 4, Received = 4, Lost = 0 (0% loss)
> ```
> `traceroute` is usually run **after ping fails** — if ping succeeds, connectivity is
> already confirmed and traceroute is normally unnecessary.

### Step 1 — verify the physical layer: interface counters

| Counter | Meaning |
|---|---|
| **Input queue drops** (+ ignored/throttle) | More traffic arrived than the router could process. Not necessarily a problem (can be normal peak traffic) — worth investigating if consistently high, and correlating with CPU usage |
| **Output queue drops** | Packets dropped from congestion on the interface. Normal at any point where aggregate input traffic exceeds output — but still causes packet loss and queuing delay, which hurts latency-sensitive apps (VoIP). Consistently high → consider an advanced queuing mechanism / QoS |
| **Input errors** | Errors during frame reception, e.g. CRC errors. High counts can mean cabling problems, interface hardware problems, or (on Ethernet) duplex mismatches |
| **Output errors** | Errors during frame transmission, e.g. collisions. In full-duplex (the norm today) collisions can't occur — so collisions, especially **late collisions**, often indicate a duplex mismatch |

### Step 2 — check for duplex mismatches

IEEE 802.3ab (Gigabit Ethernet) mandates autonegotiation of speed/duplex; virtually all Fast
Ethernet NICs also autonegotiate by default — current best practice.

Guidelines:
- Autonegotiation is recommended.
- If it fails, manually set speed **and** duplex on **both** ends.
- Point-to-point Ethernet links should always run **full-duplex**.
- Half-duplex is uncommon, typically only with legacy hubs.

> [!example] Worked example — duplex mismatch
> A second switch (S2) is added to S1 via Fa0/20 on both. Soon after, PC1 (on S1) reports
> significant performance issues reaching SRV2 (on S2). Console message on S2:
> ```
> *Mar 1 00:45:08.756: %CDP-4-DUPLEX_MISMATCH: duplex mismatch discovered on
> FastEthernet0/20 (not half duplex), with Switch FastEthernet0/20 (half duplex).
> ```
> Checking S1's side:
> ```
> S1# show interface fa 0/20
> ...
> Full-duplex, Auto-speed, media type is 10/100BaseTX
> ```
> Checking S2's side:
> ```
> S2# show interface fa 0/20
> ...
> Half-duplex, Auto-speed, media type is 10/100BaseTX
> ```
> Fix — force autonegotiation on the mismatched side:
> ```
> S2(config)# interface fa 0/20
> S2(config-if)# duplex auto
> ```
> Because S1's side is fixed full-duplex, S2 then also negotiates full-duplex. Problem
> resolved.

### Step 3 — verify addressing on the local network

In IPv4 this is **ARP**; in IPv6 it's neighbor discovery / ICMPv6, cached in a **neighbor
table**.

> [!example] Windows IPv4 ARP table
> `arp -a` lists devices currently in the ARP cache (IPv4 address, MAC, static/dynamic).
> `arp -d` clears the cache to force it to repopulate. (Linux/macOS `arp` has similar syntax.)
> ```
> C:\> arp -a
> Interface: 10.1.10.100 --- 0xd
>   Internet Address  Physical Address   Type
>   10.1.10.1          d4-8c-b5-ce-a0-c0  dynamic
>   224.0.0.22         01-00-5e-00-00-16  static
> ```

> [!example] Windows IPv6 neighbor table
> `netsh interface ipv6 show neighbor` (Linux/macOS: `ip neigh show`). Verifies destination
> IPv6 addresses map to the right MACs. Link-local addresses were manually set here: R1 =
> `FE80::1`, R2 = `FE80::2`, R3 = `FE80::3` (link-locals must be unique per link/network).
> ```
> C:\> netsh interface ipv6 show neighbor
> Internet Address           Physical Address    Type
> fe80::1                    d4-8c-b5-ce-a0-c0   Reachable (Router)
> ```

> [!example] Cisco IOS IPv6 neighbor table
> `show ipv6 neighbors` — IPv6 neighbor states are more complex than IPv4 ARP states
> (RFC 4861 has the details).
> ```
> R1# show ipv6 neighbors
> IPv6 Address                              Age Link-layer Addr State  Interface
> FE80::21E:7AFF:FE79:7A81                    8  001e.7a79.7a81  STALE  Gi0/0
> 2001:DB8:ACAD:1:5075:D0FF:FE8E:9AD8          0  5475.d08e.9ad8  REACH  Gi0/0
> ```

> [!example] Switch MAC address table
> A switch forwards to the port matching the destination MAC using its **MAC address
> table** (Layer 2 only — MAC + port, no IP info). `show mac address-table`:
> ```
> S1# show mac address-table
> Vlan  Mac Address     Type     Ports
> 10    d48c.b5ce.a0c0  DYNAMIC  Fa0/4
> 10    000f.34f9.9201  DYNAMIC  Fa0/5
> 10    5475.d08e.9ad8  DYNAMIC  Fa0/13
> ```

> [!example] Worked example — VLAN assignment problem
> Scenario: cabling in the wiring closet at S1 was reorganized; users immediately start
> reporting they can't reach devices outside their own network.
>
> **Check the ARP table** on PC1 — the entry for the default gateway (`10.1.10.1`) is
> **missing**:
> ```
> C:\> arp -a
> Interface: 10.1.10.100 --- 0xd
>   224.0.0.22   01-00-5e-00-00-16   static
>   (no entry for 10.1.10.1)
> ```
> No config changed on the router, so **S1** is the focus. **Check S1's MAC table** — R1's
> MAC is on a **different VLAN** than the rest of the `10.1.10.0/24` devices (including PC1):
> ```
> S1# show mac address-table
> Vlan  Mac Address     Type     Ports
> 1     d48c.b5ce.a0c0  DYNAMIC  Fa0/1   <- R1, but in VLAN 1!
> 10    000f.34f9.9201  DYNAMIC  Fa0/5
> 10    5475.d08e.9ad8  DYNAMIC  Fa0/13
> ```
> Root cause: during re-cabling, R1's patch cable moved from **Fa0/4 (VLAN 10)** to
> **Fa0/1 (VLAN 1)**. Fix — put Fa0/1 back in VLAN 10:
> ```
> S1(config)# interface fa0/1
> S1(config-if)# switchport mode access
> S1(config-if)# switchport access vlan 10
> S1(config-if)# exit
> S1# show mac address-table
> Vlan  Mac Address     Type     Ports
> 10    d48c.b5ce.a0c0  DYNAMIC  Fa0/1   <- fixed
> ```

### Step 4 — verify default gateway

If there's no specific route on the router, or the host has the wrong default gateway,
cross-network communication fails.

> [!example] Worked example — wrong IPv4 default gateway
> R1's default gateway (R2) is correct. PC1's should be `10.1.10.1` (R1) but isn't.
> ```
> R1# show ip route | include Gateway|0.0.0.0
> Gateway of last resort is 192.168.1.2 to network 0.0.0.0
> S*   0.0.0.0/0 [1/0] via 192.168.1.2
> ```
> ```
> C:\> route print
> IPv4 Route Table
> Network Destination   Netmask   Gateway    Interface   Metric
>        0.0.0.0        0.0.0.0  10.1.10.1  10.1.10.10   11
> ```
> If addressing was manual, fix the gateway directly on the PC. If it came from DHCPv4,
> **check the DHCP server config instead** — a DHCP misconfiguration usually affects
> **multiple clients** at once, which is itself a diagnostic clue.

> [!example] Worked example — wrong IPv6 default gateway
> IPv6 gateways can be set manually, via **SLAAC**, or via DHCPv6. With SLAAC the gateway is
> advertised by the router in ICMPv6 **Router Advertisement (RA)** messages, using the
> router interface's **link-local** address.
>
> **R1 routing table** — has a default route via R2:
> ```
> R1# show ipv6 route
> S ::/0 [1/0]
>  via 2001:DB8:ACAD:2::2
> ```
> **PC1 addressing** — `ipconfig` shows PC1 is missing a global unicast address **and** a
> default gateway (it only auto-generated its link-local, which is automatic regardless):
> ```
> C:\> ipconfig
> Link-local IPv6 Address . . . : fe80::5075:d0ff:fe8e:9ad8%13
> IPv4 Address . . . . . . . . . : 10.1.10.10
> Default Gateway. . . . . . . . : 10.1.10.1
> ```
> Documentation says this LAN should get its IPv6 info from the router via SLAAC — and
> *every* SLAAC host on this LAN would have the same problem.
>
> **Check R1's interface** — it has a global IPv6 address, but is **not** a member of the
> All-IPv6-Routers group `FF02::2` → it isn't enabled as an IPv6 router, so it never sends
> RAs on that interface:
> ```
> R1# show ipv6 interface GigabitEthernet 0/0/0
> Joined group address(es):
>     FF02::1
>     FF02::1:FF00:1
> ```
> **Fix — enable IPv6 routing:**
> ```
> R1(config)# ipv6 unicast-routing
> R1(config)# exit
> R1# show ipv6 interface GigabitEthernet 0/0/0
> Joined group address(es):
>     FF02::1
>     FF02::2      <- now a member
>     FF02::1:FF00:1
> ```
> **Verify on PC1** — now has a global unicast address and a default gateway set to R1's
> link-local:
> ```
> C:\> ipconfig
> IPv6 Address. . . . . . . . . . : 2001:db8:acad:1:5075:d0ff:fe8e:9ad8
> Link-local IPv6 Address . . . . : fe80::5075:d0ff:fe8e:9ad8%13
> Default Gateway. . . . . . . . . : fe80::1
>                                    10.1.10.1
> ```

### Step 5 — verify correct path

Routers make the forwarding decision from the routing table (`show ip route` /
`show ipv6 route` on each hop).

```
Destination IP → match in routing table?
  No  → default route configured? Yes: forward via it. No: discard the packet.
  Yes → matches more than one entry?
          No: forward out the interface of that one route.
          Yes → all matching entries have the same prefix length?
                  Yes: forward using load balancing across them.
                  No:  forward out the interface of the route with the LONGEST matching
                       prefix (longest-prefix-match / longest-bit-match wins).
```

### Step 6 — verify the transport layer

If Layer 3 checks out but users still can't reach resources, move up. Common transport
issues: ACL and NAT misconfigurations. **Telnet** is a handy transport-layer test tool
(though **SSH should be used for actual remote management**).

> [!example] Worked example — Telnet as a Layer-4 probe
> Admin can't reach R2 over HTTP. First confirm Layer 3 (and everything below) works:
> ```
> R1# ping 2001:db8:acad:2::2
> Success rate is 100 percent (5/5)
> ```
> Then confirm the transport layer with a plain Telnet (default port 23):
> ```
> R1# telnet 2001:db8:acad:2::2
> Trying 2001:DB8:ACAD:2::2 ... Open
> User Access Verification
> Password:
> R2> exit
> [Connection to 2001:db8:acad:2::2 closed by foreign host]
> ```
> Telnet client can connect to **any** TCP port, not just 23 — the connection response
> (Open / refused / timeout) tells you whether that specific service is reachable. Some
> ASCII-based application protocols even respond to keywords typed after connecting (SMTP,
> FTP, HTTP). Testing HTTP (port 80) directly:
> ```
> R1# telnet 2001:db8:acad:2::2 80
> Trying 2001:DB8:ACAD:2::2, 80 ... Open
> HTTP/1.1 400 Bad Request
> Server: cisco-IOS
> [Connection to 2001:db8:acad:2::2 closed by foreign host]
> ```
> Connection was **Open** — the transport layer works — but R2's HTTP server rejected the
> specific request (400 Bad Request). Confirms this isn't a reachability problem.

### Step 7 — verify ACLs

`show ip access-lists` / `show ipv6 access-list` display configured ACL contents (name/number
selects one specifically). `show ip interfaces` / `show ipv6 interfaces` show whether any IP
ACL is applied to a given interface.

> [!example] Worked example — an anti-spoofing ACL breaks legitimate traffic
> To block spoofing, the admin denies any packet with source `172.16.1.0/24` entering R3's
> inbound `S0/1/1` — everything else should be permitted. Shortly after, the
> `10.1.10.0/24` network can no longer reach `172.16.1.0/24` (including SRV1) at all.
>
> `show ip access-lists` confirms the ACL is configured as intended (and is matching real
> traffic — 108 hits on the deny):
> ```
> R3# show ip access-lists
> Extended IP access list 100
>     10 deny ip 172.16.1.0 0.0.0.255 any (108 matches)
>     20 permit ip any any (28 matches)
> ```
> The ACE is correct on paper — but it's blocking **return traffic** from SRV1
> (`172.16.1.0/24`) back toward `10.1.10.0/24`, since it's applied to *all* traffic entering
> that interface from that source network, including legitimate replies. (Lesson: a
> spoofing filter like this needs to be scoped/placed so it only catches traffic that
> couldn't legitimately originate there — e.g. applied only where `172.16.1.0/24` traffic
> should never appear from that direction in the first place.)

### Step 8 — verify DNS

DNS maps hostnames to IPs — once configured, you can substitute a hostname for an IP address
in any IP command (`ping`, `telnet`, …).

- `show running-config` displays the device's DNS configuration.
- Without a DNS server, use `ip host` to add a manual name→IP mapping directly on the switch/router:
  ```
  R1(config)# ip host ipv4-server 172.16.1.100
  R1(config)# exit
  ```
  Then the name works in place of the IP:
  ```
  R1# ping ipv4-server
  Sending 5, 100-byte ICMP Echos to 172.16.1.100, timeout is 2 seconds:
  !!!!!
  Success rate is 100 percent (5/5)
  ```
- On a Windows PC, use `nslookup` to check name→IP mapping.
