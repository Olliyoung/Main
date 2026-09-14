---
tags: [network-2, cisco, packet-tracer, nat, pat, overload]
aliases: ["Network 2 NAT", "PAT", "NAT overload"]
---

# 04 — NAT / PAT (internet access, R1 + R4)

> [!abstract] What & why
> R1 and R4 are edge routers. Their LAN hosts use **private** `192.168.200.x/27` addresses
> that can't be routed past the edge, so each router runs **PAT ("NAT overload")**: it
> rewrites every inside source address to its **own outside interface IP** and keeps flows
> apart by **source port number**. One public‑facing address, many inside hosts. The inside
> traffic is selected by a **standard ACL** (see [[05 - ACL]]).
>
> See also: [[00 - Overview & topology]]

## Ready config — R1 (LAN `192.168.200.0/27`, inside `G0/1`, outside `G0/0`)

```cisco
enable
configure terminal
!
! --- mark the interfaces ---
interface GigabitEthernet0/1
! LAN side = inside
 ip nat inside
exit
interface GigabitEthernet0/0
! link toward the rest of the network = outside
 ip nat outside
exit
!
! --- select which inside addresses get translated (0.0.0.31 = inverse of /27) ---
ip access-list standard NAT_R1_LAN
 permit 192.168.200.0 0.0.0.31
exit
!
! --- translate matched traffic, hide behind G0/0's IP, share via port numbers ---
ip nat inside source list NAT_R1_LAN interface GigabitEthernet0/0 overload
end
```

## Ready config — R4 (LAN `192.168.200.192/27`, inside `G0/1`, outside `G0/2`)

```cisco
enable
configure terminal
!
interface GigabitEthernet0/1
 ip nat inside
exit
interface GigabitEthernet0/2
 ip nat outside
exit
!
ip access-list standard NAT_R4_LAN
 permit 192.168.200.192 0.0.0.31
exit
!
ip nat inside source list NAT_R4_LAN interface GigabitEthernet0/2 overload
end
```

> [!warning] Common mistakes (NAT) — from our session
> - **`/27`, not `/24`.** The block steps in 32s (`.0 .32 .64 .96 .128 .160 .192`) → mask
>   `255.255.255.224`, ACL wildcard **`0.0.0.31`**. Using `0.0.0.255` selects four subnets at
>   once and breaks the intent.
> - **"Overload doesn't work both directions" — expected.** Ping from Laptop0 (behind R3) to
>   Laptop2 (behind R4) fails: both sides overload to their own outside IP and there's **no
>   translation for connections initiated from outside**. Fixing it needs **static NAT / port
>   forwarding** (`ip nat inside source static tcp ...`) — that's the bonus task, not a bug in
>   the base config.
> - **`ip nat inside` / `ip nat outside` missing or on the wrong interface.** Symptom:
>   `show ip nat translations` stays empty. Every path needs one inside and one outside.
> - **Selection ACL doesn't match the LAN** (wrong subnet or wildcard) → those hosts never get
>   translated and their private IPs leak upstream and get dropped.
> - **No default route out of the edge router** → NAT translates fine, packet has nowhere to go.
> - **Guessing interface names** — confirm inside/outside with `show ip interface brief` before
>   applying.

> [!tip] Verification (NAT)
> ```cisco
> ! live translation table - the key command
> show ip nat translations
> ! active count, hits/misses, which interfaces are inside vs outside
> show ip nat statistics
> ! just the NAT lines from the running config
> show run | section nat
> ! clear before a fresh test
> clear ip nat translation *
> ```
> **Good:** after a ping/HTTP test from a laptop, `show ip nat translations` shows rows like
> `icmp 192.168.200.33:12  192.168.200.2:12  <dst>  <dst>` — inside‑local rewritten to the
> outside interface IP, differentiated by port/ID. `show ip nat statistics` lists both an
> inside and an outside interface and `Hits` climbing.
> **Bad:** `Total number of translations: 0` after a real test → interfaces not marked, or the
> ACL doesn't match the source.

## Troubleshooting checklist (NAT)

1. Can the router itself reach the far side (routing / OSPF / default route working)? If not,
   NAT is not the problem yet.
2. `show ip nat statistics` — are **both** inside and outside interfaces listed?
3. `show ip nat translations` after a test — any rows? Empty = ACL miss or missing
   `ip nat inside/outside`.
4. Check the selection ACL: `permit 192.168.200.x` with wildcard **`0.0.0.31`**, right base
   address per router.
5. "Works out, fails in" between two NAT LANs → expected with overload; needs static NAT for
   the specific host.
