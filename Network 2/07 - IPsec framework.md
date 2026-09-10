---
tags: [network-2, cisco, ipsec, ike, esp, ah, diffie-hellman, crypto, draft]
aliases: ["IPsec", "IKE", "ESP vs AH", "IPsec framework"]
---

# 07 — IPsec framework

> [!abstract] What & why
> **IPsec** protects and authenticates IP packets between a source and destination. It's a
> **framework** — you pick an algorithm for each job, and both peers must agree. Works from
> Layer 4 up to Layer 7 (the whole payload).
>
> See also: [[06 - VPN types & tunneling]] · [[08 - Site-to-site IPsec VPN (config)]]

## What IPsec provides (the four services)

| Service | Question it answers | Provided by |
|---|---|---|
| **Confidentiality** | can anyone read it? | encryption — AES, 3DES, (DES) |
| **Integrity** | was it changed in transit? | hash / HMAC — SHA, (MD5) |
| **Origin authentication** | is the peer who it claims to be? | PSK or RSA digital certificates |
| **Anti-replay / key exchange** | fresh keys, no replayed packets | Diffie-Hellman (DH groups) |

## The IPsec framework — pick one per column

> [!todo] Fill in the choices we use in the lab
> | Job | Options | Our choice |
> |---|---|---|
> | Encapsulation | AH · ESP | todo |
> | Confidentiality | DES · 3DES · AES-128/192/256 | todo |
> | Integrity | MD5 · SHA | todo |
> | Authentication | PSK · RSA (certificates) | todo |
> | DH group | 1/2/5 (avoid) · 14/15/16 (2048/3072/4096-bit) · 19/20/21/24 (ECC) | todo |

## AH vs ESP (encapsulation)

| | AH (protocol 51) | ESP (protocol 50) |
|---|---|---|
| Integrity + authentication | ✅ | ✅ |
| **Encryption (confidentiality)** | ❌ | ✅ |
| NAT-friendly | ❌ (breaks with NAT) | ✅ (with NAT-T) |
| Use in practice | rare | **default choice** |

## Transport mode vs tunnel mode

> [!todo] Add the packet diagrams from the module video
> - **Transport mode** — original IP header kept; only the payload is protected. Host-to-host.
> - **Tunnel mode** — the **entire original packet** is encrypted and wrapped in a new IP
>   header. Gateway-to-gateway (site-to-site). This is the usual site-to-site mode.

## IKE — how the tunnel is negotiated

> [!todo] Expand phase 1 / phase 2
> - **IKE Phase 1 (ISAKMP SA)** — authenticate the peers, run Diffie-Hellman, build a secure
>   management channel. Main mode / aggressive mode (IKEv1) or IKEv2.
> - **IKE Phase 2 (IPsec SA)** — negotiate the actual data-protection parameters (transform
>   set), one SA per direction. Optionally a fresh DH exchange (PFS).

### Diffie-Hellman groups

- DH groups **1, 2, 5** — legacy, **do not use**.
- DH groups **14, 15, 16** — 2048 / 3072 / 4096-bit keys.
- DH groups **19, 20, 21, 24** — Elliptic Curve (ECC); smaller keys, faster.

### Peer authentication

- **PSK (pre-shared key)** — same secret typed into each peer. Easy, doesn't scale, must be
  on every peer.
- **RSA / digital certificates** — each peer authenticates the other with a certificate.
  Scales; needs a PKI.

## Common mistakes

> [!warning] To fill in from our session
> - todo (mismatched transform sets, DH group, PSK, lifetimes; interesting-traffic ACLs not
>   mirrored; NAT in the path without NAT-T…)

## Verification

> [!tip] To fill in
> - `show crypto isakmp sa` — Phase 1 state (want `QM_IDLE` / `ACTIVE`)
> - `show crypto ipsec sa` — Phase 2; watch `pkts encrypt` / `pkts decrypt` climb
> - todo
