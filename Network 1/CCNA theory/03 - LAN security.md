---
tags: [network-1, ccna, srwe, theory, port-security, bpdu-guard, vlan-attacks, dhcp-snooping, aaa, dot1x]
aliases: ["Port security modes", "VLAN hopping", "802.1X", "DHCP snooping", "CDP LLDP"]
---

# 03 — LAN security

> [!info] Related
> Config commands are in [[04 - Security]]. This is the checkpoint‑exam theory.

## Port security — violation modes

| Mode | Drops traffic | Shuts port | Logs / notifies | Increments counter |
|---|---|---|---|---|
| **shutdown** (default) | yes | yes (err‑disabled) | yes | yes |
| **restrict** | yes | no | yes | yes |
| **protect** | yes | no | **no** | no |

- Use **protect** when the policy is "drop unknown MACs and send **no** notification".
- A configured static secure MAC + a different device connecting → violation (default =
  shutdown).
- `show port-security interface …` → current status, max MACs, sticky MACs, violation count.

## VLAN hopping — mitigation (three techniques)

1. Set the **native VLAN** to an unused VLAN.
2. **Disable DTP** (`switchport nonegotiate`).
3. **Enable trunking manually** only on required ports (`switchport mode trunk`); everything
   else forced to `access`.

## BPDU Guard

- Applied to PortFast **access** ports.
- A BPDU arriving on such a port → the port is **err‑disabled** (blocks a rogue switch).
- Enable: `spanning-tree portfast bpduguard enable` · Remove: `no` form.
- Check: `show errdisable recovery`, `show interfaces status`.

## DHCP snooping & starvation

- **Starvation:** attacker floods DHCP DISCOVERs with spoofed MACs → the pool empties →
  legitimate clients cannot get an address.
- **Mitigate:** port security + DHCP snooping.
- **Snooping:** trust only the ports facing a legitimate DHCP server / the path to it;
  client‑facing ports stay untrusted. Rate‑limit with `ip dhcp snooping limit rate N`
  (exceeding it → err‑disable).

## 802.1X authentication — three roles

- **Supplicant** — the client device requesting access
- **Authenticator** — the switch (or AP) controlling the port
- **Authentication Server** — usually a **RADIUS** server

## AAA

- **Authentication** = who you are (usernames / passwords)
- **Authorization** = what you're allowed to do
- **Accounting** = what you did (logs)
- AAA is the framework; **RADIUS** is the actual server protocol. 802.1X *uses* authentication
  — it is not itself "the user/pass component".

## Discovery protocols (CDP / LLDP)

- Disable both on interfaces where they aren't required — especially edge / user ports.

## Quick memory aids

- Port Security default = **shutdown**
- **Protect** = drop + silent
- **Supplicant** = client
- RADIUS shared secret = secures **WLC ↔ RADIUS** messages only, not end‑user auth
