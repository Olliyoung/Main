---
tags: [network-2, cisco, packet-tracer, ipsec, site-to-site, crypto-map, vpn]
aliases: ["Site-to-site VPN config", "IPsec tunnel config", "crypto map", "VPN-MAP"]
---

# 08 — Site-to-site IPsec VPN (config)

> [!abstract] What & why
> Connect two sites' LANs over an untrusted path with an encrypted **tunnel-mode IPsec**
> tunnel between the two edge routers. Hosts send normal traffic; the gateways do the crypto.
> Only traffic matching an **"interesting traffic" ACL** goes into the tunnel — everything
> else passes in clear text. Concepts: [[07 - IPsec framework]].
>
> Lab: *Packet Tracer — Configure and Verify a Site-to-Site IPsec VPN* (R1 ↔ R3 via R2).

## Topology for this lab

```
PC-A ── S1 ── R1 ═══ R2 ═══ R3 ── S3 ── PC-C
192.168.1.0/24   10.1.1.0/30  10.2.2.0/30   192.168.3.0/24
```

| | R1 (site A) | R3 (site B) |
|---|---|---|
| LAN to protect | `192.168.1.0/24` (G0/0 = .1) | `192.168.3.0/24` (G0/0 = .1) |
| Tunnel (outside) interface | **S0/0/0** = `10.1.1.2` | **S0/0/1** = `10.2.2.2` |
| Peer address (far end) | `10.2.2.2` | `10.1.1.2` |
| Interesting-traffic ACL 110 | `permit ip 192.168.1.0 → 192.168.3.0` | `permit ip 192.168.3.0 → 192.168.1.0` (mirror) |

> [!note] R2 is a pass-through
> R2 (`10.1.1.1`, `10.2.2.1`) just routes — **no VPN config**. Routing is already done with
> OSPF 101, so both routers can reach each other's serial before you start.

## ISAKMP Phase 1 — parameters used

| Parameter | Value | Default? |
|---|---|---|
| Key distribution | ISAKMP | — |
| Encryption | **AES 256** | no → must set |
| Hash | SHA‑1 | yes |
| Authentication | **pre‑share** | no → must set |
| DH group | **5** | no → must set (PT max is 5; prod ≥ 24) |
| SA lifetime | 86400 s | yes |
| Pre‑shared key | `vpnpa55` | — |

## IPsec Phase 2 — parameters used

| Parameter | Value |
|---|---|
| Transform set name | `VPN-SET` |
| ESP encryption | `esp-aes` |
| ESP authentication | `esp-sha-hmac` |
| Crypto map name | `VPN-MAP`, seq `10`, type `ipsec-isakmp` |

## Prerequisite — enable the security license

```cisco
! crypto commands are rejected until the security package is active
show version                      ! look for securityk9 under current tech packages
configure terminal
 license boot module c1900 technology-package securityk9
! accept the EULA, then:
end
write memory
reload                            ! required for the license to take effect
show version                      ! confirm securityk9 = active
```

## Ready config — R1

```cisco
enable
configure terminal
!
! --- 1. interesting traffic: R1 LAN -> R3 LAN (implicit deny handles the rest) ---
access-list 110 permit ip 192.168.1.0 0.0.0.255 192.168.3.0 0.0.0.255
!
! --- 2. IKE Phase 1 policy (only the non-default bits) ---
crypto isakmp policy 10
 encryption aes 256
 authentication pre-share
 group 5
exit
! pre-shared key, pointed at R3's SERIAL (the far tunnel endpoint)
crypto isakmp key vpnpa55 address 10.2.2.2
!
! --- 3. IKE Phase 2 transform set ---
crypto ipsec transform-set VPN-SET esp-aes esp-sha-hmac
!
! --- 4. crypto map ties peer + transform set + interesting traffic together ---
crypto map VPN-MAP 10 ipsec-isakmp
 description VPN connection to R3
 set peer 10.2.2.2
 set transform-set VPN-SET
 match address 110
exit
!
! --- 5. bind the map to the OUTSIDE interface ---
interface s0/0/0
 crypto map VPN-MAP
exit
end
write memory
```

## Ready config — R3 (mirror image)

```cisco
enable
configure terminal
!
! interesting traffic reversed: R3 LAN -> R1 LAN
access-list 110 permit ip 192.168.3.0 0.0.0.255 192.168.1.0 0.0.0.255
!
crypto isakmp policy 10
 encryption aes 256
 authentication pre-share
 group 5
exit
crypto isakmp key vpnpa55 address 10.1.1.2
!
crypto ipsec transform-set VPN-SET esp-aes esp-sha-hmac
!
crypto map VPN-MAP 10 ipsec-isakmp
 description VPN connection to R1
 set peer 10.1.1.2
 set transform-set VPN-SET
 match address 110
exit
!
interface s0/0/1
 crypto map VPN-MAP
exit
end
write memory
```

## Verification (Part 3)

```cisco
! BEFORE interesting traffic - all counters 0
R1# show crypto ipsec sa
    #pkts encaps: 0, #pkts encrypt: 0, #pkts digest: 0
    #pkts decaps: 0, #pkts decrypt: 0, #pkts verify: 0

! create interesting traffic: from PC-A, ping PC-C (192.168.3.3)
! (first ping or two may drop while the tunnel negotiates)

! AFTER - encrypt AND decrypt climbing = tunnel works
R1# show crypto ipsec sa
    #pkts encaps: 4, #pkts encrypt: 4, #pkts digest: 4
    #pkts decaps: 4, #pkts decrypt: 4, #pkts verify: 4

! Phase 1 SA - want QM_IDLE / ACTIVE between 10.1.1.2 and 10.2.2.2
R1# show crypto isakmp sa

! prove only interesting traffic is encrypted:
! from PC-A ping PC-B (192.168.2.3) - NOT in ACL 110
! re-run show crypto ipsec sa -> counters DID NOT change
```

> [!tip] Good vs bad
> **Good:** `show crypto isakmp sa` shows one peer, state `QM_IDLE`; `show crypto ipsec sa`
> has `#pkts encrypt` **and** `#pkts decrypt` both increasing after a PC‑to‑PC ping.
> **Bad:**
> - no ISAKMP SA at all → Phase 1 mismatch (encryption / hash / group / auth / key) or no
>   route to the peer's serial
> - ISAKMP up, `#pkts encrypt` climbing but `#pkts decrypt = 0` → R3's ACL 110 isn't the
>   mirror, or R3's crypto map isn't applied / wrong interface
> - counters stay 0 even from PC‑A → crypto map not on the interface, or you tested from the
>   router instead of the PC

## ⚠️ Common mistakes (this lab)

> [!warning]
> - **`securityk9` not enabled** → every `crypto …` command silently fails. `show version`
>   must list it; if not, enable the license, `write`, `reload`.
> - **ACL 110 not mirrored** — R1 is `src 192.168.1.0 dst 192.168.3.0`; R3 is the exact
>   reverse. If they don't mirror, Phase 2 never forms.
> - **`set peer` pointing at R2** — the peer is the **far router's serial**
>   (R1 → `10.2.2.2`, R3 → `10.1.1.2`), *not* R2's serials (`10.1.1.1` / `10.2.2.1`).
> - **Crypto map on the wrong interface** — R1 = `S0/0/0`, R3 = `S0/0/1` (the interface
>   facing R2). Not the LAN interface.
> - **Testing with a router ping** — `ping` from R1 sources `10.1.1.2`, which isn't in
>   `192.168.1.0/24`, so it's not interesting. Ping **from PC‑A to PC‑C**.
> - **Key mismatch** — both sides `vpnpa55`.
> - **DH group** — PT only supports up to `group 5`; a real network would use `group 24`+.

## 🧭 Troubleshooting checklist

1. Routing first: can R1 `ping 10.2.2.2` (R3's serial)? If not, fix OSPF / interfaces — the
   VPN can't build over an unreachable peer.
2. `show version` on both → `securityk9` active?
3. `show crypto isakmp sa` → Phase 1 up? If not, diff `show run | section crypto isakmp`
   between R1 and R3 (encryption / hash / group / auth) and check the key + peer address.
4. `show crypto ipsec sa` → Phase 2 up? encrypt climbing but not decrypt → problem is on the
   **peer** side (ACL mirror, transform set, crypto map on interface).
5. `show access-lists 110` on both → exact mirrors?
6. `show crypto map` → peer, transform-set, `match address 110`, and "Interfaces using
   crypto map" all present?
7. Test from **PC‑A → PC‑C**, then confirm PC‑A → PC‑B leaves the counters unchanged.
