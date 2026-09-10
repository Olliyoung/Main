---
tags: [network-2, cisco, vpn, ssl, anyconnect, dmvpn, mpls, draft]
aliases: ["Remote-access VPN", "SSL VPN", "Provider VPN", "MPLS VPN"]
---

# 09 — Remote-access & provider VPNs

> [!abstract] What & why
> The other two big VPN buckets: a **single user** dialing into the enterprise (remote-access)
> and VPNs the **carrier** provides between your sites (MPLS). Site-to-site enterprise IPsec is
> [[08 - Site-to-site IPsec VPN (config)]]; concepts/taxonomy is [[06 - VPN types & tunneling]].

## Remote-access VPN — IPsec vs SSL

| | IPsec remote access | SSL / TLS VPN |
|---|---|---|
| Client | dedicated IPsec client | web browser (**clientless**) or a light client (e.g. AnyConnect) |
| Ports / transport | ESP + IKE (UDP 500/4500) — often blocked on guest wifi | TCP/UDP **443** — almost always open |
| What it reaches | full network (like being on the LAN) | clientless = specific web apps; full client = full network |
| Typical use | company laptops | any device, contractors, kiosks |

> [!todo] Fill in
> - AnyConnect (full tunnel vs split tunnel)
> - clientless SSL VPN portal — what it can and can't do
> - headend device (ASA / router / concentrator) in our setup

## Enterprise multi-site — DMVPN & IPsec VTI (recap)

> [!todo] Expand from [[06 - VPN types & tunneling]]
> - **DMVPN** — hub-and-spoke; spokes register with the hub (NHRP) and build **dynamic
>   spoke-to-spoke** tunnels on demand. Scales to many branches.
> - **IPsec VTI** — a routable `Tunnel` interface protected by an IPsec profile; no crypto
>   maps / no interesting-traffic ACL. Simpler for many tunnels.

## Service-provider VPNs — MPLS

> [!todo] Fill in
> - **MPLS L3VPN** — provider routes customer prefixes in per-customer VRFs; customers exchange
>   routes with the provider (PE–CE). Separation, **not encryption**.
> - **MPLS L2VPN** (VPWS / VPLS) — provider carries customer Layer 2 frames; customer sites
>   look like one switch / one wire.
> - Customer wanting confidentiality over MPLS still runs its own IPsec on top.

## Common mistakes

> [!warning] To fill in
> - todo

## Verification

> [!tip] To fill in
> - todo
