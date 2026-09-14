---
tags: [network-2, ensa, theory, network-design, hierarchical, scalability]
aliases: ["Hierarchical Networks", "Scalable Networks", "Module 11"]
---

# 11 — Network Design

> ENSA Module 11 notes: hierarchical network design and scalability. Pure theory — no lab
> commands here. See also [[01 - Layer 2 foundation]] for the EtherChannel/trunk mechanics
> mentioned below, and [[03 - OSPF]] for routing-protocol tuning.

## 11.1 Hierarchical Networks

### Why scale the network

Users now expect access from anywhere, any time, any device. Next-generation networks must
be secure, reliable, and highly available, **and** still integrate legacy platforms as the
business grows (more employees, branch offices, global markets). A **Network Operations
Center (NOC)** typically centralizes management of a geographically spread enterprise
(multiple sites connected over the internet, plus remote/mobile workers).

Enterprise networks must:
- Support critical applications
- Support converged traffic (data, voice/IP telephony, video)
- Support diverse business needs
- Provide centralized administrative control

A **campus network** = a group of interconnected LANs spread over a small geographic area,
from a single switch up to a network with thousands of connections.

### Borderless switched networks

The **Cisco Borderless Network** is an architecture that lets an organization connect
anyone, anywhere, any time, on any device — securely, reliably, seamlessly. It unifies
wired and wireless access (policy, access control, performance management) on a scalable,
resilient **hierarchical hardware infrastructure**, combined with policy-based software to
provide two service sets: **network services** and **user/endpoint services**.

Campus sizes scale the same building blocks:

| Size | Typical blocks |
|---|---|
| Small campus | Data Center + Services Block, connects to WAN/Internet |
| Medium campus | Data Center + Services Block |
| Large campus | Data Center + Services Block **and** an Internet Edge block (firewall, edge routers) |

### Hierarchy in the borderless switched network — four design principles

| Principle | What it means |
|---|---|
| **Hierarchical** | Clarifies each device's role per tier, simplifies deployment/operation/management, reduces fault domains at every tier |
| **Modularity** | Allows seamless expansion and on-demand service enablement |
| **Resiliency** | Keeps the network available, meeting user expectations of "always on" |
| **Flexibility** | Allows intelligent load sharing using all network resources |

Two proven frameworks built on these principles: the **three-tier** and **two-tier** models,
made of three critical layers — **access, distribution, core** — each a well-defined,
structured module with specific roles.

### Access, Distribution, and Core layer functions

| Layer | Function |
|---|---|
| **Access** | Network edge — where traffic enters/exits the campus. Primary job: give users network access. Connects up to distribution switches, which implement routing/QoS/security. Next-gen access switches push more converged/integrated/intelligent services to the edge. |
| **Distribution** | Interfaces between access and core: aggregates large-scale wiring-closet networks; aggregates L2 broadcast domains and L3 routing boundaries; provides intelligent switching/routing/access-policy; high availability via redundant distribution switches + equal-cost paths to core; differentiated services per traffic class at the edge. |
| **Core** | The backbone. Connects multiple distribution layers, aggregates all distribution devices, ties the campus together. Primary purpose: **fault isolation** and **high-speed backbone connectivity**. |

### Three-tier vs two-tier examples

> [!example] Three-tier (access / distribution / core kept separate)
> Recommended for organizations that need a simplified, scalable, cost-effective,
> efficient physical cable layout — build an **extended-star** topology from a centralized
> building (core) out to every other building (each with its own access + distribution).
> Example: Building A (core/management) in the middle, Buildings B/C/D/E/F each with their
> own access+distribution pair around it.

> [!example] Two-tier / collapsed core (distribution and core combined)
> Used where extensive physical/network scalability isn't needed — smaller campuses, fewer
> users, or a single building. The distribution and core functions run on the **same**
> device ("collapsed distribution/core"). Example: a single building with access switches
> per floor all uplinking to one collapsed distribution/core switch, which connects to the
> WAN/Internet router.

### Role of switched networks

Flat Layer 2 switched networks (Ethernet + hubs propagating traffic everywhere) have given
way to **hierarchical switched LANs**: core (C1/C2, connected to edge routers) →
distribution (D1–D4) → access (S1–S6) → end devices. A switched LAN adds flexibility,
traffic management, QoS, security, and supports wireless and IP telephony/mobility.

---

## 11.2 Scalable Networks

### Design for scalability

Scalability = a network that can grow **without losing availability and reliability**.
Basic strategy:
- Use expandable/modular/clustered equipment — add modules instead of forklift-upgrading.
- Design the hierarchy so one layer (e.g. access) can expand without touching the others.
- Create a **hierarchical** IPv4/IPv6 addressing strategy — careful planning avoids
  re-addressing the whole network to add users/services.
- Use routers or multilayer switches to **limit broadcasts** and filter unwanted traffic;
  Layer 3 devices reduce traffic reaching the core.

### Advanced design requirements

| Requirement | What it gives you |
|---|---|
| **Redundant links** | Implemented between critical devices and between access↔core layer devices — no single point of failure |
| **Multiple links** | Link aggregation (**EtherChannel**) or equal-cost load balancing combines several Ethernet links into one logical, load-balanced link — increases bandwidth without buying faster interfaces/fiber |
| **Scalable routing protocol** | Use a protocol (and its features) that **isolates routing updates** and minimizes routing-table size — e.g. splitting an OSPF domain into areas (Area 1 / Area 0 / Area 51) |
| **Wireless connectivity** | Add mobility/expansion via a Cisco Wireless Access Point off the access layer, alongside wired PCs |

### Plan for redundancy

Redundancy prevents disruption from a single point of failure — either by **duplicate
equipment** (failover for critical devices) or **redundant physical paths**.

> [!warning] Redundant paths can loop
> Redundant paths in a switched Ethernet network can cause **Layer 2 loops** — **Spanning
> Tree Protocol (STP)** is required to eliminate them by disabling redundant paths until
> they're actually needed (e.g. on failure).
>
> Alternative: implement **Layer 3** in the backbone instead of L2 redundancy — avoids
> needing STP, and gives best-path selection + faster failover convergence.

### Reduce failure domain size

A **failure domain** = the area of the network impacted when a critical device or service
fails. Impact depends on the role of the device that fails — a bad access switch affects
only its segment; a failed router connecting segments has a much bigger impact.

- Redundant links + reliable enterprise-class equipment minimize disruption.
- Smaller failure domains reduce the productivity hit **and** simplify/shorten
  troubleshooting.
- Easiest and cheapest place to control failure-domain size: the **distribution layer** —
  errors are contained to a smaller area, affecting fewer users, because every router there
  acts as a gateway for a limited number of access-layer users.

> [!info] Switch block deployment
> Routers or multilayer switches are usually deployed **in pairs**, with access layer
> switches evenly split between them — a **switch block** (a.k.a. building/departmental
> block). Each block operates independently, so one device (or even a whole block) failing
> doesn't take the network down or hit a large number of users.

### Increase bandwidth (EtherChannel)

Some access↔distribution links carry more converged traffic than others and can become a
bottleneck. **EtherChannel** bundles several physical links into one logical link:
- Uses existing switch ports — no need to buy faster/more expensive interfaces or run fiber.
- Seen and configured as **one EtherChannel interface** — most config happens there instead
  of per physical port, keeping the links consistent.
- Gets load balancing across the bundled links (method depends on the hardware platform).

### Expand the access layer

Wireless is an increasingly important way to extend access-layer connectivity — more
flexibility, lower cost, easier growth. Requires a wireless NIC (radio + driver) on the end
device, and a **wireless router or access point (AP)** for it to connect to. Design
considerations: device types, coverage, interference, and security.

### Tune routing protocols

Advanced link-state protocols like **OSPF** suit large hierarchical networks needing fast
convergence: routers form neighbor adjacencies, synchronize their link-state database, and
flood link-state updates on a change so every router recomputes the best path. Splitting a
large OSPF domain into **areas** is a scalability technique (limits how far updates/SPF
recalculation propagate) — see [[03 - OSPF]].

---

## 11.4 Router Requirements

Routers connect homes/businesses to the internet, interconnect multiple sites within an
enterprise, provide redundant paths, and connect ISPs together. A router can also translate
between media types/protocols (e.g. re-encapsulate Ethernet frames for a serial link).

Routers pick the outbound path using the **network portion (prefix)** of the destination IP,
and select an alternate path if a link goes down. Every host's IP config names a local
router interface as its **default gateway**.

Other router functions:
- **Broadcast containment** — limits broadcasts to the local network.
- **Interconnect geographically separated locations.**
- **Group users logically** by application/department based on shared needs or shared
  resource access.
- **Enhanced security** — filter unwanted traffic with ACLs (see [[05 - ACL]]).
