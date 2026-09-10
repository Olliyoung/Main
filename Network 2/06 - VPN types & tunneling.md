---
tags: [network-2, cisco, vpn, tunneling, gre, dmvpn, mpls, ssl, draft]
aliases: ["VPN types", "VPN concepts", "Tunneling"]
---

# 06 — VPN types & tunneling

> [!abstract] What & why
> A **VPN** carries private traffic across a public/untrusted network by **encrypting** it, so
> it stays confidential in transit. Benefits: **cost savings** (internet instead of leased
> lines), **security**, **scalability**, **compatibility**.
>
> See also: [[07 - IPsec framework]] · [[08 - Site-to-site IPsec VPN (config)]] · [[00 - Overview & topology]]

## Two ways to classify a VPN

### By who connects — topology

| Type | What it connects | Terminating device | Traffic from the host |
|---|---|---|---|
| **Site-to-site** | whole network ↔ whole network, across an untrusted network | VPN **gateway** at each site | normal unencrypted TCP/IP; the gateway does the crypto |
| **Remote-access** | a single mobile/remote user ↔ the enterprise | VPN client ↔ headend (ASA / router / concentrator) | client builds the encrypted tunnel itself; can be **IPsec** or **SSL** |

### By who runs it — management

| Type | Managed by | Examples |
|---|---|---|
| **Enterprise** | the organisation itself | IPsec site-to-site, GRE over IPsec, DMVPN, IPsec VTI, SSL remote access |
| **Service-provider** | the ISP / carrier | MPLS **L3VPN** and **L2VPN** (customer traffic separated in the provider core) |

## Tunneling technologies

> [!todo] Fill in per technology as we cover it
> For each: what it does · secure? · scales? · typical use.

| Technology | Secure (encrypts)? | Notes | Status |
|---|---|---|---|
| **GRE** | ❌ no | generic tunnel; carries multicast/routing protocols that plain IPsec can't; usually wrapped **GRE over IPsec** | todo |
| **IPsec** | ✅ yes | confidentiality + integrity + authentication; site-to-site and remote access | → [[07 - IPsec framework]] |
| **GRE over IPsec** | ✅ yes | GRE for the routing/multicast, IPsec for the encryption | todo |
| **DMVPN** | ✅ yes | hub-and-spoke that builds **dynamic spoke-to-spoke** tunnels on demand; scales to many sites | todo |
| **IPsec VTI** | ✅ yes | tunnel interface instead of crypto maps; simpler config for many sites / remote access | todo |
| **SSL / TLS VPN** | ✅ yes | remote access via browser (clientless) or a lightweight client; no IPsec client needed | → [[09 - Remote-access & provider VPNs]] |
| **MPLS L3VPN / L2VPN** | ❌ (separation, not encryption) | provider keeps customers' routes/frames separate in the core | todo |

## When to use which

> [!todo] Decision notes
> - Need to run OSPF/EIGRP or multicast across the tunnel → GRE (over IPsec).
> - Many sites, meshy traffic → DMVPN.
> - Simple config, many tunnels → IPsec VTI.
> - Roaming users, no client push → SSL VPN.
> - Just two sites, encrypted → plain site-to-site IPsec ([[08 - Site-to-site IPsec VPN (config)]]).

## Common mistakes

> [!warning] To fill in from our session
> - todo

## Verification

> [!tip] To fill in
> - todo
