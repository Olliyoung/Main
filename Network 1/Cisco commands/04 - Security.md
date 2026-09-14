---
tags: [network-1, cisco, packet-tracer, port-security, bpdu-guard, black-hole-vlan, ccna, srwe]
aliases: ["Port security", "BPDU Guard", "Black-hole VLAN", "err-disabled recovery"]
---

# 04 — Security (port security · BPDU Guard · black-hole VLAN)

> [!abstract] What & why
> Layer‑2 hardening for user‑facing ports. **Port security** limits which / how many MACs a
> port accepts. **BPDU Guard** err‑disables a PortFast access port the moment it receives a
> BPDU (someone plugged in a rogue switch). A **black‑hole VLAN** parks every unused port in a
> dead VLAN and shuts it, so an opportunistic patch‑in gets nothing.

## Port security

```cisco
configure terminal
interface range FastEthernet0/1-24
! turn the feature on
 switchport port-security
! at most 2 MACs on the port
 switchport port-security maximum 2
! what to do on violation (shutdown is the default)
 switchport port-security violation shutdown
! learn the first MAC(s) automatically and save them into running-config
 switchport port-security mac-address sticky
exit
end
```

| Violation mode | Drops traffic | Shuts port | Logs / notifies | Counter |
|---|---|---|---|---|
| `shutdown` (default) | yes | yes (err‑disabled) | yes | yes |
| `restrict` | yes | no | yes | yes |
| `protect` | yes | no | **no** | no |

> [!note] When to use `protect`
> Policy says "drop unknown MACs, send **no** notification". A configured static secure MAC +
> a different device connecting = violation (default action shutdown).

## BPDU Guard (on PortFast access ports)

```cisco
configure terminal
interface range FastEthernet0/1-24
! access-port fast transition to forwarding
 spanning-tree portfast
! any BPDU in => err-disable the port
 spanning-tree bpduguard enable
exit
end
```

```cisco
! remove it from one port
interface FastEthernet0/10
 no spanning-tree portfast bpduguard enable
```

## Recover an err-disabled port

```cisco
interface FastEthernet0/10
 shutdown
 no shutdown
```

```cisco
! see which features auto-recover err-disabled ports and the timer
show errdisable recovery
```

## Black-hole VLAN

```cisco
configure terminal
vlan 666
 name BlackHole
exit
! move every UNUSED port into it and shut them
interface range FastEthernet0/5-24
 switchport mode access
 switchport access vlan 666
 shutdown
exit
end
write memory
```

> [!warning] Common mistakes
> - **`bpduguard` on a trunk / uplink** → the first legitimate BPDU err‑disables your uplink.
>   PortFast + BPDU Guard belong on **access** ports only.
> - **Port stays err‑disabled after you "fixed" it** → you must bounce it (`shutdown` /
>   `no shutdown`) or wait for `errdisable recovery`.
> - **Sticky MACs "lost" after reload** → you didn't `write memory` after they were learned.
> - **`maximum` too low for a phone + PC** (phone + PC on one port = 2+ MACs) → set `maximum`
>   accordingly or use `switchport voice vlan`.

> [!tip] Verification
> ```cisco
> show port-security                       ! per-port status + violation count
> show port-security interface Fa0/1       ! detail: max, sticky, last violating MAC
> show port-security address               ! learned secure MACs
> show interfaces status                   ! look for "err-disabled"
> show running-config interface Fa0/18     ! confirm bpduguard / portfast lines
> ```
