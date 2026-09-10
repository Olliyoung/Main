---
tags: [network-2, cisco, packet-tracer, hsrp, fhrp, redundancy]
aliases: ["Network 2 HSRP", "Hot Standby Router Protocol"]
---

# 02 — HSRP (redundant default gateway, R2 + R3)

> [!abstract] What & why
> Hosts in VLAN 10/20 get **one** default gateway. HSRP lets R2 and R3 share a **virtual IP**
> (`192.168.10.1` / `192.168.20.1`) that hosts point at. R2 (priority 110) is **Active** and
> forwards; R3 is **Standby** and takes over in ~10 s if R2's Hellos stop. `preempt` lets R2
> reclaim Active after it recovers. Configured per VLAN subinterface, and paired with
> [[03 - OSPF]] so both routers actually have a path upstream to fail over to.
>
> Prerequisite: [[01 - Layer 2 foundation]] must be solid first.

## Ready config — R2 (Active)

```cisco
enable
configure terminal
!
! --- physical parent interface must be UP before subinterfaces work ---
interface GigabitEthernet0/0
! no IP on the parent; just enable it
 no shutdown
exit
!
! --- VLAN 10 gateway ---
interface GigabitEthernet0/0.10
! tag this subinterface to VLAN 10 (must match the switch VLAN + the trunk allow-list)
 encapsulation dot1Q 10
! THIS ROUTER'S OWN real address in the VLAN 10 subnet - REQUIRED for HSRP to work
 ip address 192.168.10.2 255.255.255.0
! shared virtual IP the hosts use as their default gateway
 standby 10 ip 192.168.10.1
! higher priority => R2 becomes Active
 standby 10 priority 110
! reclaim Active automatically after a reboot / link recovery
 standby 10 preempt
exit
!
! --- VLAN 20 gateway ---
interface GigabitEthernet0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.2 255.255.255.0
 standby 20 ip 192.168.20.1
 standby 20 priority 110
 standby 20 preempt
exit
!
! --- link toward the core (for OSPF) ---
interface GigabitEthernet0/1
 ip address 10.10.10.1 255.255.255.252
 no shutdown
exit
end
```

## Ready config — R3 (Standby)

```cisco
enable
configure terminal
!
interface GigabitEthernet0/0
 no shutdown
exit
!
interface GigabitEthernet0/0.10
 encapsulation dot1Q 10
! R3's own address - different host, same subnet as R2
 ip address 192.168.10.3 255.255.255.0
! SAME group number + SAME virtual IP as R2
 standby 10 ip 192.168.10.1
! no priority line => default 100 => stays Standby while R2 is healthy
 standby 10 preempt
exit
!
interface GigabitEthernet0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.3 255.255.255.0
 standby 20 ip 192.168.20.1
 standby 20 preempt
exit
!
interface GigabitEthernet0/2
 ip address 10.10.20.1 255.255.255.252
 no shutdown
exit
end
```

> [!warning] Common mistakes (HSRP) — from our session
> - **Subinterface had `encapsulation dot1Q` but `no ip address`** (R2 `G0/0.10`). HSRP needs
>   the subinterface to have its **own** IP in the VLAN subnet. Without it HSRP can't operate.
> - **Subinterface missing BOTH `encapsulation dot1Q` and `ip address`** (R2 `G0/0.20`). With
>   no encapsulation the subinterface isn't tagged to VLAN 20 at all — that HSRP group is
>   completely dead.
> - **Ignoring `% Warning: address ... not within subnet` when setting `standby X ip`.** That
>   message was the real clue that the subinterface had no IP in the subnet — not noise.
> - **Both routers show themselves `Active` and the peer as `unknown` / `local`.** They can't
>   hear each other's Hellos → it's a **Layer 2 trunk problem** ([[01 - Layer 2 foundation]]),
>   not HSRP config.
> - **Testing by pinging the virtual IP.** Ping R3's **real** address (`192.168.10.3`) from R2
>   to test the L2/L3 path — the VIP can be answered locally and hides the problem.
> - **`preempt` missing on R2** — after a reboot R2 comes back as Standby and R3 stays Active.
> - **Priorities/encapsulation not matching between R2 and R3** — the two subinterface configs
>   must mirror each other exactly except for the real host IP and R2's `priority 110`.

> [!tip] Verification (HSRP)
> ```cisco
> ! one line per group: state, virtual IP, priority, preempt flag, peer address
> show standby brief
> ! full detail: peer IP, timers, virtual MAC, active/standby routers
> show standby
> ! did the subinterfaces actually get their IPs? (not "unassigned")
> show ip interface brief
> ```
> **Good:** on R2 `show standby brief` shows groups 10 and 20 as `Active`, `P` (preempt) flag
> set, priority `110`, and **"Standby router" = `192.168.10.3`** (R3's real IP). On R3 the same
> groups show `Standby` with "Active router" = `192.168.10.2`.
> **Bad:** state `Active` on *both* routers with peer `unknown`; or state flapping
> `Speak`/`Listen`; or `show ip interface brief` shows `G0/0.20` as `unassigned`.

## Troubleshooting checklist (HSRP)

1. **Layer 2 path first.** From R2: `ping 192.168.10.3` (R3's *real* IP). Fails →
   [[01 - Layer 2 foundation]]: trunk `allowed vlan add`, VLAN exists, every hop including
   switch→router G0/1, STP not blocking.
2. `show running-config interface g0/0.10` and `.20` on **both** routers — is
   `encapsulation dot1Q` present **and** is there an `ip address` in the right subnet? Do the
   two routers mirror each other?
3. `show ip interface brief` — subinterface IPs assigned, parent `G0/0` up/up?
4. `show standby brief` on both — same **group number** and same **virtual IP**? `preempt` on
   R2? Priority `110` on R2?
5. Did you see and act on any `% address not within subnet` warning?
6. Test failover: `shutdown` R2's `G0/1` (or `G0/0`) and watch R3 take Active in
   `show standby brief`.
