---
tags: [network-2, cisco, ipsec, site-to-site, crypto-map, kommandoer, opgave, modul8]
aliases: ["Site-to-site VPN kommandoer", "IPsec kommandoer forklaret", "Configure and Verify a Site-to-Site IPsec VPN"]
---

# 08 — Site-to-site IPsec VPN: kommandoer forklaret (pr. step)

> Følger opgavens opbygning: **Del 1 (R1)**, **Del 2 (R3)**, **Del 3 (verificér)**.
> Under hvert step står kommandoen fra opgaven + hvad den gør.
> Brug det til at **forstå** kommandoerne — skriv din aflevering med dine egne ord.
> Koncepter: [[07 - IPsec framework]] · [[06 - VPN types & tunneling]].

## Indhold

- [[#Reference — adresser og parametre]]
- [[#Del 1 — Konfigurér IPsec på R1]] · Step 1 · 2 · 3 · 4 · 5 · 6
- [[#Del 2 — Konfigurér IPsec på R3]] · Step 1 · 2 · 3 · 4 · 5
- [[#Del 3 — Verificér VPN'en]] · Step 1 · 2 · 3 · 4 · 5 · 6

---

## Reference — adresser og parametre

### De to tunnel-ender

| | R1 | R3 |
|---|---|---|
| LAN der beskyttes | `192.168.1.0/24` (G0/0 = .1) | `192.168.3.0/24` (G0/0 = .1) |
| Ydre interface (mod R2) | **S0/0/0** = `10.1.1.2` | **S0/0/1** = `10.2.2.2` |
| Peer = modpartens ydre IP | `10.2.2.2` | `10.1.1.2` |

> R2 (`10.1.1.1` / `10.2.2.1`) er kun gennemgang og har **ingen** VPN-config.
> OSPF 101 og alle passwords er sat i forvejen.

### IKE Phase 1 (ISAKMP policy 10) — samme på R1 og R3

| Parameter | Værdi | Default? |
|---|---|---|
| Key distribution | ISAKMP | — |
| Encryption | **AES 256** | nej → skal skrives |
| Hash | SHA-1 | ja |
| Authentication | **pre-share** | nej → skal skrives |
| Key exchange (DH) | **group 5** | nej → skal skrives |
| IKE SA lifetime | 86400 s | ja |
| ISAKMP key | `vpnpa55` | — |

### IPsec Phase 2 — samme på R1 og R3

| Parameter | Værdi |
|---|---|
| Transform set navn | `VPN-SET` |
| ESP encryption | `esp-aes` |
| ESP authentication | `esp-sha-hmac` |
| Peer IP | R1 → `10.2.2.2` · R3 → `10.1.1.2` |
| Interessant trafik | `access-list 110` (R1: kilde .1 → dest .3 · R3: spejlvendt) |
| Crypto map navn | `VPN-MAP` |
| SA establishment | `ipsec-isakmp` |

---

## Del 1 — Konfigurér IPsec på R1

### Step 1 — Test forbindelsen

Fra **PC-A**, ping **PC-C** (`192.168.3.3`). Routing er sat op, så det skal virke.
Virker det ikke → find routing-fejlen først. VPN'en kan ikke bygges oven på en forbindelse
der ikke er der.

### Step 2 — Slå Security Technology-pakken til

- **a.** `show version` — se hvilke technology packages der er licenseret. Kig efter
  `securityk9`.
- **b.** Hvis den ikke er slået til:
  ```cisco
  license boot module c1900 technology-package securityk9
  ```
  Aktiverer security-licensen på 1900-routeren. **Uden den bliver alle `crypto`-kommandoer
  afvist.**
- **c.** Accepter slutbrugerlicensen (svar `yes`).
- **d.** `write` (gem) og `reload` (genstart) — licensen træder først i kraft efter genstart.
- **e.** `show version` igen → `securityk9` skal nu stå under de aktive packages.

### Step 3 — Identificér interessant trafik på R1

```cisco
access-list 110 permit ip 192.168.1.0 0.0.0.255 192.168.3.0 0.0.0.255
```

- **"Interessant trafik"** = den trafik der skal **ind i tunnelen** (krypteres). Al anden
  trafik fra LAN'et sendes ukrypteret.
- `110` = ACL-nummer i den udvidede række, så vi kan matche **både kilde og destination**.
- `permit ip` — her betyder `permit` *"kryptér denne trafik"*, ikke "tillad" som i en firewall.
  `ip` = al IP-trafik.
- `192.168.1.0 0.0.0.255` = **kilde**: R1's LAN. `0.0.0.255` er wildcard-masken (det omvendte
  af `255.255.255.0`).
- `192.168.3.0 0.0.0.255` = **destination**: R3's LAN.
- Man behøver ikke skrive `deny ip any any` — den **implicitte deny** sørger for at alt andet
  ikke bliver krypteret.

### Step 4 — IKE Phase 1 ISAKMP-policy på R1

Phase 1 = de to routere autentificerer hinanden og bygger en sikker kanal til at aftale
resten. Kun de ikke-default parametre skal skrives (encryption, authentication, DH).

```cisco
crypto isakmp policy 10
 encryption aes 256
 authentication pre-share
 group 5
 exit
crypto isakmp key vpnpa55 address 10.2.2.2
```

- `crypto isakmp policy 10` — går ind i Phase 1-politik nr. `10`. Nummeret er en
  **prioritet**: lavest nummer prøves først. Politikken skal matche på R3.
- `encryption aes 256` — krypterer **selve Phase 1-forhandlingen** med AES 256-bit
  (ikke brugertrafikken). Default er `des`, derfor skal linjen skrives.
- `authentication pre-share` — de to routere beviser hvem de er med en **fælles hemmelig
  nøgle** (i stedet for certifikater). Default er `rsa-sig`, derfor skal linjen skrives.
- `group 5` — **Diffie-Hellman-gruppe 5**. DH bruges til at udveksle krypteringsnøglerne
  sikkert. Packet Tracer's max er 5 (i produktion mindst 24). Default er `1`.
- `crypto isakmp key vpnpa55 address 10.2.2.2` — den fælles nøgle `vpnpa55`, **bundet til
  modpartens IP** (`10.2.2.2` = R3's serial). På R3 bindes samme nøgle til `10.1.1.2`.

### Step 5 — IKE Phase 2 IPsec-policy på R1

Phase 2 = aftal hvordan **den rigtige trafik** beskyttes.

**a. Transform-set**
```cisco
crypto ipsec transform-set VPN-SET esp-aes esp-sha-hmac
```
- Laver et navngivet sæt (`VPN-SET`) af de algoritmer der beskytter data:
  - `esp-aes` = ESP med AES til **kryptering** af data.
  - `esp-sha-hmac` = ESP med SHA-HMAC til **integritet** (tjek at pakken ikke er ændret).

**b. Crypto map**
```cisco
crypto map VPN-MAP 10 ipsec-isakmp
 description VPN connection to R3
 set peer 10.2.2.2
 set transform-set VPN-SET
 match address 110
 exit
```
- `crypto map VPN-MAP 10 ipsec-isakmp` — "samlekassen" der binder Phase 2 sammen.
  `10` = sekvensnummer. `ipsec-isakmp` = brug IKE til at forhandle tunnelen automatisk. | Laver et crypto map navngivet VPN-MAP, med sekvens nummeret 10.
- `description …` — bare en note.
- `set peer 10.2.2.2` — hvem den anden ende er: **modpartens ydre IP** (ikke R2).
- `set transform-set VPN-SET` — hvilket transform-set (fra a) der skal bruges.
- `match address 110` — hvilken ACL der definerer den interessante trafik → `access-list 110`.
 
### Step 6 — Sæt crypto map på det udgående interface

```cisco
interface s0/0/0
 crypto map VPN-MAP
```

- Aktiverer crypto map'et på **interfacet mod R2/internettet** (`S0/0/0` på R1).
- **Først her træder VPN'en i kraft.** Du får beskeden `ISAKMP is ON`.

---

## Del 2 — Konfigurér IPsec på R3

R3 får **de samme parametre, spejlvendt**.

### Step 1 — Slå Security Technology-pakken til

Som [[#Step 2 — Slå Security Technology-pakken til|Del 1 Step 2]]: `show version`, og hvis
`securityk9` ikke er aktiv → slå den til og `reload` R3.

### Step 2 — Interessant trafik på R3 (spejlvendt)

```cisco
access-list 110 permit ip 192.168.3.0 0.0.0.255 192.168.1.0 0.0.0.255
```

- Præcis **omvendt** af R1: kilde = R3's LAN (`192.168.3.0`), destination = R1's LAN
  (`192.168.1.0`).
- Hvis de to ACL'er ikke er spejlvendte, dannes Phase 2 aldrig.

### Step 3 — IKE Phase 1 ISAKMP på R3

```cisco
crypto isakmp policy 10
 encryption aes 256
 authentication pre-share
 group 5
 exit
crypto isakmp key vpnpa55 address 10.1.1.2
```

- Samme policy som R1 (skal matche).
- Nøglen bindes til **R1's** ydre IP: `10.1.1.2`.

### Step 4 — IKE Phase 2 IPsec-policy på R3

**a. Transform-set** — samme som R1:
```cisco
crypto ipsec transform-set VPN-SET esp-aes esp-sha-hmac
```

**b. Crypto map** — samme, men peer peger på R1:
```cisco
crypto map VPN-MAP 10 ipsec-isakmp
 description VPN connection to R1
 set peer 10.1.1.2
 set transform-set VPN-SET
 match address 110
 exit
```

### Step 5 — Sæt crypto map på det udgående interface

```cisco
interface s0/0/1
 crypto map VPN-MAP
```

- På R3 er det interface mod R2 **`S0/0/1`** (ikke S0/0/0). *(Ikke bedømt i opgaven.)*

---

## Del 3 — Verificér VPN'en

### Step 1 — Tjek tunnelen FØR interessant trafik

```cisco
show crypto ipsec sa
```
På R1: `#pkts encaps`, `encrypt`, `decaps`, `decrypt` er alle **0** — der er ikke sendt
noget gennem tunnelen endnu.

### Step 2 — Lav interessant trafik

Fra **PC-A**, ping **PC-C** (`192.168.3.3`).
(De første 1–2 pings kan fejle mens tunnelen forhandles — normalt.)

### Step 3 — Tjek tunnelen EFTER interessant trafik

```cisco
show crypto ipsec sa
```
Nu er tællerne **> 0** → tunnelen virker. `#pkts encrypt` og `#pkts decrypt` skal begge
stige.

Ekstra:
```cisco
show crypto isakmp sa
```
Én linje mellem `10.1.1.2` og `10.2.2.2`, state `QM_IDLE` = Phase 1 er oppe.

### Step 4 — Lav uinteressant trafik

Fra **PC-A**, ping **PC-B** (`192.168.2.3`).

> Ping **fra en router** (R1 → PC-C) tæller ikke som interessant trafik — afsenderen bliver
> routerens egen serial-IP, som ikke er i `192.168.1.0/24`.

### Step 5 — Tjek tunnelen igen

```cisco
show crypto ipsec sa
```
Tællerne har **ikke ændret sig** → uinteressant trafik krypteres ikke. Det beviser at kun
ACL 110-trafik går i tunnelen.

### Step 6 — Check Results

Skal give **100 %**. Klik *Check Results* for at se hvad der mangler.

---

## Hvis noget ikke virker

> [!important] Begge routere skal være konfigureret
> IPsec kræver **symmetrisk opsætning**. R3 alene gør ingenting — R1 skal have den
> spejlvendte config (peer = `10.2.2.2`, ACL 110 kilde `192.168.1.0` → dest `192.168.3.0`,
> crypto map på `S0/0/0`) før tunnelen kan komme op.

| Symptom | Betyder / tjek |
|---|---|
| `crypto`-kommandoer afvises | `securityk9` ikke slået til / router ikke genstartet |
| `show crypto isakmp sa` viser **`MM_NO_STATE`** (evt. `ACTIVE (deleted)`) | Phase 1 kom kun til første besked — **den anden router svarer ikke**: R1 er ikke konfigureret endnu, eller R1↔R3 kan ikke nå hinandens WAN-IP i forvejen |
| Ingen linje overhovedet i `show crypto isakmp sa` | ingen interessant trafik har trigget tunnelen endnu (ping fra **PC**, ikke fra routeren), eller Phase 1-parametre matcher ikke |
| `#pkts encrypt` stiger, `#pkts decrypt` = 0 | fejl på **modparten**: ACL 110 ikke spejlvendt, transform-set matcher ikke, eller crypto map ikke på interfacet |
| Tællerne rører sig slet ikke, selv fra PC-A | crypto map ikke sat på interfacet, eller sat på det forkerte interface |

> [!tip] Tjek grund-connectivity først
> Fra R3: `ping 10.1.1.2` (R1's WAN-IP). Fejler den → routing/OSPF mellem R1 og R3 virker
> ikke, og VPN'en kan aldrig komme op. Trig så tunnelen med **ping fra PC-C til PC-A** (ikke
> fra routerens CLI — så bliver kilde-IP'en routerens egen serial og matcher ikke ACL 110).
