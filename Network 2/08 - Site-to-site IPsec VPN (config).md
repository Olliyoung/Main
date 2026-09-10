---
tags: [network-2, cisco, packet-tracer, ipsec, site-to-site, crypto-map, gre, draft]
aliases: ["Site-to-site VPN config", "IPsec tunnel config", "crypto map"]
---

# 08 — Site-to-site IPsec VPN (config)

> [!abstract] What & why
> Connect two whole sites over the internet with an encrypted **tunnel-mode IPsec** tunnel
> between the two edge routers (VPN gateways). Hosts send normal traffic; the gateways do the
> crypto. Concepts: [[07 - IPsec framework]].
>
> See also: [[06 - VPN types & tunneling]] · [[00 - Overview & topology]]

## Topology / addressing for this tunnel

> [!todo] Fill in when we set it up
> | | Site A gateway | Site B gateway |
> |---|---|---|
> | Public (outside) IP | todo | todo |
> | Inside LAN to protect | todo | todo |
> | Outside interface | todo | todo |

## Ready config — the 5 pieces (repeat mirrored on each peer)

> [!todo] Values to be filled from the lab

```cisco
enable
configure terminal
!
! --- 1. IKE Phase 1 policy (ISAKMP) - both peers must match ---
crypto isakmp policy 10
 encryption aes 256
 hash sha
 authentication pre-share
 group 14
 lifetime 3600
exit
!
! --- 2. Pre-shared key, pointed at the OTHER peer's public IP ---
crypto isakmp key <SHARED-SECRET> address <PEER-PUBLIC-IP>
!
! --- 3. IKE Phase 2 transform set (how data is protected) ---
crypto ipsec transform-set TS esp-aes 256 esp-sha-hmac
 mode tunnel
exit
!
! --- 4. "Interesting traffic" ACL - which flows go INTO the tunnel ---
!     MUST be the mirror image of the peer's ACL
ip access-list extended VPN-TRAFFIC
 permit ip <LOCAL-LAN> <wildcard> <REMOTE-LAN> <wildcard>
exit
!
! --- 5. Crypto map: tie peer + transform set + interesting traffic together ---
crypto map CMAP 10 ipsec-isakmp
 set peer <PEER-PUBLIC-IP>
 set transform-set TS
 match address VPN-TRAFFIC
exit
!
! --- apply the crypto map to the OUTSIDE interface ---
interface <OUTSIDE-IF>
 crypto map CMAP
exit
end
```

## Option — GRE over IPsec

> [!todo] Add if the lab needs routing protocols / multicast across the tunnel
> - Build a `interface Tunnel0` (GRE) between the two public IPs.
> - Protect the GRE with an IPsec profile (`tunnel protection ipsec profile …`) instead of a
>   crypto map on the physical interface.
> - Interesting traffic becomes just "GRE between the two public IPs".

## Common mistakes

> [!warning] To fill in from our session
> - Interesting-traffic ACLs not exact mirrors on the two peers
> - Phase 1 params mismatch (encryption / hash / DH group / auth / lifetime)
> - Transform set mismatch
> - `crypto map` on the wrong interface (must be the outside/public one)
> - PSK typed against the wrong peer address
> - NAT ahead of the tunnel translating the "interesting" traffic before it's matched → add a
>   `deny` for the VPN traffic at the top of the NAT ACL
> - No route to the peer's public IP / tunnel traffic

## Verification

> [!tip] Good vs bad output
> ```cisco
> show crypto isakmp sa      ! Phase 1 - want state QM_IDLE / ACTIVE with the peer
> show crypto ipsec sa       ! Phase 2 - "pkts encrypt" AND "pkts decrypt" both climbing
> show crypto map            ! peer, transform set, match ACL all present
> show crypto session        ! UP-ACTIVE
> debug crypto isakmp        ! last resort - watch the negotiation fail
> ```
> **Good:** ISAKMP SA present and `ACTIVE`; `pkts encrypt` and `pkts decrypt` both increase
> when you ping across.
> **Bad:** no ISAKMP SA → Phase 1 mismatch or no reachability; ISAKMP up but `pkts decrypt = 0`
> → peer's interesting-traffic ACL / transform set doesn't match, or return routing broken.

## Troubleshooting checklist

> [!todo] Order it once we've hit the real faults
> 1. Reachability: can each gateway ping the other's **public** IP?
> 2. `show crypto isakmp sa` — Phase 1 up? If not → compare `crypto isakmp policy` + PSK.
> 3. `show crypto ipsec sa` — Phase 2 up? encrypt climbing but not decrypt → peer side.
> 4. Interesting-traffic ACLs exact mirrors?
> 5. NAT not eating the VPN traffic (deny VPN subnets at top of NAT ACL)?
> 6. Routing: does each side have a route back to the remote LAN?
