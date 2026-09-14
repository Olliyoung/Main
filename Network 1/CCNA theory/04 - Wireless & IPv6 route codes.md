---
tags: [network-1, ccna, srwe, theory, wireless, wlan, capwap, ipv6]
aliases: ["Wireless channels", "CAPWAP", "WLAN best practices", "IPv6 route codes"]
---

# 04 — Wireless & IPv6 route codes

> [!info] Source
> From the CCNA checkpoint note files.

## Wireless quick facts

- **CAPWAP** tunnel between a lightweight AP and the WLC — UDP **5246 / 5247**.
- 2.4 GHz non‑overlapping channels: **1, 6, 11**.
- **5 GHz** has more channels and is usually less crowded → better for high‑bandwidth
  services (video streaming).
- Mixed b/g clients + a new dual‑band AP → split traffic: old clients on 2.4 GHz, capable
  clients on 5 GHz.
- Microwave ovens cause accidental 2.4 GHz interference.

## Home AP — best practice (change these three)

1. **AP admin password** (management login)
2. **Wireless passphrase** (WPA2 / WPA3)
3. **SSID** (network name)

## RADIUS shared secret

Used only to encrypt / authenticate messages **between the WLC and the RADIUS server**.
It is **not** used to authenticate end users.

## IPv6 route codes

| Code | Meaning | AD |
|---|---|---|
| `C` | connected | 0 |
| `L` | local address | 0 |
| `S` | static | 1 |
| `O` | OSPF | 110 |
| `R` | RIP | 120 |

- Default route prefix: `::/0`
