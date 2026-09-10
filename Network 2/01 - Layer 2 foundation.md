---
tags: [network-2, cisco, packet-tracer, layer2, trunk, etherchannel, vlan]
aliases: ["Network 2 Layer 2", "Trunks and EtherChannel"]
---

# 01 — Layer 2 foundation (trunks, EtherChannel, VLANs)

> [!abstract] What & why
> HSRP, inter‑VLAN routing and the router subinterfaces all ride on VLANs 10/20 crossing the
> switch fabric. If a VLAN isn't carried across **every** trunk in the path — the
> switch‑to‑switch EtherChannel **and** the switch‑to‑router link — the two routers can't hear
> each other's HSRP Hellos and both declare themselves Active. This was the root cause of
> almost every "HSRP is broken" symptom in our session.
>
> See also: [[00 - Overview & topology]] · [[02 - HSRP]]

## Ready config — switches (run on SW1 / SW2 / SW3 as needed)

```cisco
enable
configure terminal
!
! --- 1. The VLANs must EXIST on the switch before a trunk can carry them ---
vlan 10
 name vlan-10
exit
vlan 20
 name vlan-20
exit
!
! --- 2. Inter-switch EtherChannel: ADD the VLANs, never replace the list ---
interface Port-channel1
! make sure it's a trunk
 switchport mode trunk
! "add" appends 10 and 20; a bare "allowed vlan 10,20" would WIPE VLAN 1 + everything else
 switchport trunk allowed vlan add 10,20
exit
!
! --- 3. The link UP to the router (router-on-a-stick / HSRP) must also be a trunk with 10,20 ---
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan add 10,20
exit
!
end
```

> [!danger] The mistake that cost the most time
> `switchport trunk allowed vlan 10,20` **replaces the entire allowed‑VLAN list** — it silently
> drops VLAN 1 and any other VLAN that was on the trunk. Always use:
> `switchport trunk allowed vlan add 10,20`
> To see the damage / confirm the fix: `show interfaces trunk` → the "Vlans allowed on trunk"
> column must read `1,10,20`, not just `1`.

> [!warning] Common mistakes (Layer 2) — from our session
> - **`allowed vlan` without `add`** — wiped the list, broke everything downstream (see above).
> - **VLAN 10/20 never created on the switch** — `switchport trunk allowed vlan add` "works"
>   but the VLAN isn't active, so frames don't pass. Create `vlan 10` / `vlan 20` first.
> - **Only fixed the switch‑to‑switch trunk (Po1), forgot the switch‑to‑router trunk (G0/1).**
>   HSRP Hellos still didn't reach the far router. Every trunk in the path needs 10 and 20.
> - **Assumed which switch was which.** SW2/SW3 naming was swapped vs. the diagram — always
>   confirm with `show cdp neighbors` / the actual `hostname`, don't trust the label.
> - **Spanning tree blocking a path** — if a redundant link puts a VLAN's port in *blocking*,
>   HSRP multicast can't get through even though the VLAN is "allowed".

> [!tip] Verification (Layer 2)
> ```cisco
> ! which VLANs actually cross each trunk? want: 1,10,20
> show interfaces trunk
> ! do VLAN 10 and 20 exist and have the right access ports?
> show vlan brief
> ! any port stuck BLK (blocking) instead of FWD for VLAN 10 / 20?
> show spanning-tree vlan 10
> show spanning-tree vlan 20
> ```
> **Good:** every trunk in `show interfaces trunk` lists `1,10,20` under both "Vlans allowed
> on trunk" and "Vlans allowed and active in management domain"; STP shows the needed ports
> `FWD`.
> **Bad:** a trunk shows only `1`; or a VLAN 10 port shows `BLK`.

## Troubleshooting checklist (Layer 2)

1. `show interfaces trunk` on **every** switch — does each trunk (Po1 **and** the G0/1 to the
   router) carry `1,10,20`? If not → `switchport trunk allowed vlan add 10,20`.
2. `show vlan brief` — do VLAN 10 and 20 exist? If not → create them, then re‑add to trunks.
3. `show spanning-tree vlan 10 | 20` — any needed port `BLK`? Check for an accidental loop.
4. Confirm you fixed the trunk on **both ends** and on **every hop**, not just one switch.
5. Only then move to [[02 - HSRP]].
