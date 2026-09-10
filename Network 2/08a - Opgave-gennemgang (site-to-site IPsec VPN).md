---
tags: [network-2, cisco, packet-tracer, ipsec, site-to-site, opgave, gennemgang]
aliases: ["Opgave site-to-site VPN", "IPsec VPN walkthrough", "Configure and Verify a Site-to-Site IPsec VPN"]
---

# 08a — Opgave-gennemgang: Configure and Verify a Site-to-Site IPsec VPN

> [!abstract] Hvad går opgaven ud på
> Lav en krypteret **site-to-site IPsec-tunnel mellem R1 og R3**. Trafik mellem
> `192.168.1.0/24` (R1's LAN) og `192.168.3.0/24` (R3's LAN) skal krypteres. **R2 er kun
> gennemgang** og ved intet om VPN'en. Routing (OSPF 101) er sat op i forvejen.
>
> Følg trinene i rækkefølge → `Check Results` skal give **100 %**.
> Reference/uddybning: [[08 - Site-to-site IPsec VPN (config)]] · koncepter: [[07 - IPsec framework]].

## Adresser (kun det du skal bruge)

| | R1 | R3 |
|---|---|---|
| LAN der beskyttes | `192.168.1.0/24` | `192.168.3.0/24` |
| Ydre interface (tunnel-enden) | **S0/0/0** = `10.1.1.2` | **S0/0/1** = `10.2.2.2` |
| Peer = modpartens serial | `10.2.2.2` | `10.1.1.2` |

> [!warning] Peer er den ANDEN routers serial — ikke R2
> R2's serials (`10.1.1.1`, `10.2.2.1`) bruges aldrig i VPN-konfigurationen.

## Parametre (fra opgaven)

**Phase 1 (ISAKMP), policy 10** — ens på begge:
`encryption aes 256` · `authentication pre-share` · `group 5` · hash SHA-1 (default) ·
lifetime 86400 (default) · nøgle `vpnpa55`

**Phase 2 (IPsec):**
transform-set `VPN-SET` = `esp-aes esp-sha-hmac` · crypto map `VPN-MAP` seq `10` `ipsec-isakmp` ·
match `access-list 110`

---

## Del 1 — R1

### Trin 1: Test forbindelse først

Fra **PC-A**, ping **PC-C**:
```
ping 192.168.3.3
```
Skal virke (routing er sat op). Hvis ikke → fejl i routing, ikke VPN — stop og find den først.

### Trin 2: Slå security-pakken til (securityk9)

```cisco
enable
show version
```
Kig efter `securityk9` under "Technology Package License Information". Hvis den **ikke** er
`enabled`:
```cisco
configure terminal
 license boot module c1900 technology-package securityk9
```
- Accepter EULA (svar `yes`).
```cisco
 end
 write memory
 reload
```
Efter reload: `show version` igen → `securityk9` skal stå som aktiv. **Uden den bliver alle
`crypto`-kommandoer afvist.**

### Trin 3: Definér interessant trafik (ACL 110)

```cisco
configure terminal
! trafik FRA R1's LAN TIL R3's LAN = det der skal i tunnelen
access-list 110 permit ip 192.168.1.0 0.0.0.255 192.168.3.0 0.0.0.255
```
Tjek:
```cisco
do show access-lists 110
```
Forventet: `10 permit ip 192.168.1.0 0.0.0.255 192.168.3.0 0.0.0.255`, `0 match(es)` (helt normalt — den bruges ikke endnu).

### Trin 4: IKE Phase 1 (ISAKMP-policy + nøgle)

```cisco
crypto isakmp policy 10
! kryptér selve opsætnings-snakken mellem R1 og R3
 encryption aes 256
! peers beviser sig med en fælles hemmelig nøgle
 authentication pre-share
! nøgleudvekslings-gruppe (PT understøtter max 5)
 group 5
exit
! den fælles nøgle, bundet til R3's serial-adresse
crypto isakmp key vpnpa55 address 10.2.2.2
```

### Trin 5: IKE Phase 2 (transform-set + crypto map)

```cisco
! hvordan den RIGTIGE trafik pakkes: ESP med AES + SHA
crypto ipsec transform-set VPN-SET esp-aes esp-sha-hmac
!
! crypto map samler peer + transform-set + interessant trafik
crypto map VPN-MAP 10 ipsec-isakmp
 description VPN connection to R3
 set peer 10.2.2.2
 set transform-set VPN-SET
 match address 110
exit
```

### Trin 6: Sæt crypto map på det udgående interface

```cisco
interface s0/0/0
 crypto map VPN-MAP
exit
end
write memory
```
Du ser beskeden `%CRYPTO-6-ISAKMP_ON_OFF: ISAKMP is ON` — det er godt.

---

## Del 2 — R3 (spejlvendt af R1)

### Trin 1: securityk9

Samme som R1 Trin 2. `show version` → slå til + `reload` hvis nødvendigt.

### Trin 2: Interessant trafik (spejlvendt ACL)

```cisco
enable
configure terminal
! FRA R3's LAN TIL R1's LAN - præcis omvendt af R1
access-list 110 permit ip 192.168.3.0 0.0.0.255 192.168.1.0 0.0.0.255
```

### Trin 3: IKE Phase 1

```cisco
crypto isakmp policy 10
 encryption aes 256
 authentication pre-share
 group 5
exit
! nøglen bundet til R1's serial
crypto isakmp key vpnpa55 address 10.1.1.2
```

### Trin 4: IKE Phase 2

```cisco
crypto ipsec transform-set VPN-SET esp-aes esp-sha-hmac
!
crypto map VPN-MAP 10 ipsec-isakmp
 description VPN connection to R1
 set peer 10.1.1.2
 set transform-set VPN-SET
 match address 110
exit
```

### Trin 5: Crypto map på interface

```cisco
interface s0/0/1
 crypto map VPN-MAP
exit
end
write memory
```

---

## Del 3 — Verificér tunnelen

### Trin 1: Før trafik — tællere på 0

```cisco
R1# show crypto ipsec sa
```
Forventet:
```
#pkts encaps: 0, #pkts encrypt: 0, #pkts digest: 0
#pkts decaps: 0, #pkts decrypt: 0, #pkts verify: 0
```

### Trin 2: Lav interessant trafik

Fra **PC-A**, ping **PC-C**:
```
ping 192.168.3.3
```
(de første 1-2 pings kan fejle mens tunnelen bygges — det er normalt)

### Trin 3: Efter trafik — tællere over 0

```cisco
R1# show crypto ipsec sa
```
Nu er `#pkts encrypt` **og** `#pkts decrypt` > 0 → **tunnelen virker.**

Ekstra tjek:
```cisco
R1# show crypto isakmp sa
```
Forventet: én linje, state `QM_IDLE`, mellem `10.1.1.2` og `10.2.2.2`.

### Trin 4-5: Uinteressant trafik ændrer ikke tællerne

Fra **PC-A**, ping **PC-B**:
```
ping 192.168.2.3
```
```cisco
R1# show crypto ipsec sa
```
Tællerne er **uændrede** → kun interessant trafik krypteres. Perfekt.

> [!warning] Ping fra routeren tæller ikke
> `ping` fra R1 til PC-C har afsender `10.1.1.2` — det matcher ikke ACL 110. Test altid
> **fra PC-A til PC-C**.

### Trin 6: Check Results

Skal give **100 %**.

---

## 🧭 Hvis du ikke får 100 % / tunnelen ikke kommer op

1. Kan R1 `ping 10.2.2.2`? Hvis ikke → routing-problem, ikke VPN.
2. `show version` på begge → er `securityk9` aktiv?
3. `show crypto isakmp sa` → ingen linje? Sammenlign Phase 1 på de to routere:
   `show run | section crypto isakmp` — `encryption` / `authentication` / `group` / nøgle /
   peer-adresse skal passe.
4. `show crypto ipsec sa` → `encrypt` stiger men `decrypt` bliver 0 → fejlen er på **R3**
   (spejl-ACL, transform-set, eller crypto map ikke på interface).
5. `show access-lists 110` på begge → er de præcis spejlvendte?
6. `show crypto map` → står peer, transform-set, `match address 110` og "Interfaces using
   crypto map" der?
7. Testede du fra **PC-A**, ikke fra routeren?

## De klassiske fejl

> [!warning]
> - Glemt `securityk9` → `crypto`-kommandoer virker ikke.
> - ACL 110 ikke spejlvendt (R1: 1→3, R3: 3→1).
> - `set peer` peger på R2 i stedet for den anden router.
> - Crypto map på det forkerte interface (R1 = S0/0/0, R3 = S0/0/1).
> - Forskellig nøgle på de to sider.
> - Testet med ping fra routeren i stedet for fra PC-A.
