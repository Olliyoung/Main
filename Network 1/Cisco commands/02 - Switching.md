---
tags: [network-1, cisco, packet-tracer, vlan, trunk, etherchannel, stp, ccna, srwe]
aliases: ["VLANs", "Trunking", "EtherChannel", "Spanning tree"]
---

# 02 — Switching (VLANs · trunking · EtherChannel · STP)

> [!abstract] What & why
> VLANs split one physical switch into separate broadcast domains. **Access ports** carry one
> VLAN to an end device; **trunk ports** carry many VLANs (tagged 802.1Q) between switches and
> up to a router. **EtherChannel** bundles several links into one logical trunk for bandwidth
> + redundancy. **STP** stops loops by blocking redundant paths.

## Create VLANs (paste block — all switches)

```cisco
configure terminal
vlan 10
 name Sales
vlan 20
 name IT
vlan 30
 name Management
vlan 40
 name Servers
vlan 99
 name Native
exit
end
write memory
```

## Access ports

```cisco
configure terminal
! select a block of ports
interface range FastEthernet0/1-10
! never negotiate - force access mode
 switchport mode access
! put them in VLAN 10
 switchport access vlan 10
 no shutdown
exit
end
```

## Trunk to another switch / to a router

```cisco
configure terminal
interface GigabitEthernet0/1
! force trunking (don't rely on DTP negotiation)
 switchport mode trunk
! native VLAN = untagged VLAN; make it a dedicated unused VLAN and match both ends
 switchport trunk native vlan 99
! only carry the VLANs you actually need
 switchport trunk allowed vlan 10,20,30,40,99
 no shutdown
exit
end
```

> [!danger] `allowed vlan` overwrites — use `add` when the trunk already exists
> `switchport trunk allowed vlan 10,20` **replaces** the whole list (drops VLAN 1 + anything
> else). To append to a live trunk:
> `switchport trunk allowed vlan add 10,20`
> This exact trap broke HSRP in the Network 2 lab — see [[01 - Layer 2 foundation]].

## EtherChannel (LACP) — between two switches

```cisco
configure terminal
! bundle the physical members
interface range FastEthernet0/1-4
! on a 2960, trunk encapsulation is dot1q only (3560/3650 need this line explicitly)
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk native vlan 99
! "active" = LACP; both sides active (or one active + one passive) forms the channel
 channel-group 1 mode active
 no shutdown
exit
!
! configure the logical interface once - members inherit it
interface Port-channel 1
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk native vlan 99
exit
end
write memory
```

> [!warning] Common mistakes (VLAN / trunk / EtherChannel)
> - **Trunk left as `dynamic auto` on both ends** → no trunk forms; force `switchport mode trunk`.
> - **Native VLAN mismatch** between the two trunk ends → `%CDP-4-NATIVE_VLAN_MISMATCH`.
> - **VLAN used on a trunk but never created** on the switch → frames for it are dropped.
> - **`allowed vlan` without `add`** on an existing trunk → wipes the list.
> - **EtherChannel won't come up** → member ports don't match (speed / duplex / mode / allowed
>   VLANs / native VLAN must be identical on all members and both switches).
> - **One side `mode active`, other side `mode on`** → no LACP negotiation, channel stays down.

> [!tip] Verification
> ```cisco
> show vlan brief                 ! VLANs + access ports
> show interfaces trunk           ! trunk mode, native VLAN, allowed + active VLANs
> show etherchannel summary       ! P = in port-channel, look for (SU) / (P) flags
> show interfaces Port-channel 1
> ```

## Spanning Tree — find the root bridge

```cisco
! overall STP state (all VLANs)
show spanning-tree
! per-VLAN: who is root, which local ports are Root/Designated/Blocking
show spanning-tree vlan 10
show spanning-tree vlan 20
```

> [!note] Reading `show spanning-tree vlan X`
> If "This bridge is the root" appears, this switch is root for that VLAN. Otherwise the
> **Root ID** section shows the root's MAC and the local **Root Port** toward it. Ports in
> `BLK` (blocking) are STP‑disabled to break a loop — expected on redundant links, a problem
> if it blocks a path you need.
