---
tags: [network-2, cisco, ipsec, site-to-site, crypto-map, kommandoer, modul8]
aliases: ["Site-to-site VPN kommandoer", "IPsec kommandoer forklaret", "crypto map"]
---

# 08 — Site-to-site IPsec VPN: kommandoer forklaret

> Noter til opgaven *Configure and Verify a Site-to-Site IPsec VPN* (R1 ↔ R3 via R2).
> Her står **hvad hver kommando gør** — konfigurationslinjerne er givet i opgaven i Learn.
> Koncepter: [[07 - IPsec framework]] · [[06 - VPN types & tunneling]].

## Rækkefølgen

1. Slå security-pakken til (ellers virker `crypto`-kommandoerne ikke)
2. Definér **interessant trafik** (ACL)
3. **IKE Phase 1** — ISAKMP-policy + nøgle
4. **IKE Phase 2** — transform-set + crypto map
5. Sæt crypto map på det udgående interface
6. Test

---

## 1. Security-pakke

```cisco
show version
```
Viser bl.a. hvilke technology packages der er aktive. Du skal se **`securityk9`**.

```cisco
license boot module c1900 technology-package securityk9
```
Slår security-licensen til på en 1900-router. Uden den bliver **alle `crypto`-kommandoer
afvist**. Bagefter: accepter EULA, `write`, og `reload` (licensen kræver genstart).

---

## 2. Interessant trafik (ACL)

```cisco
access-list 110 permit ip 192.168.1.0 0.0.0.255 192.168.3.0 0.0.0.255
```
Definerer hvilken trafik der skal **ind i tunnelen** ("interessant trafik").

- `110` = ACL-nummer (udvidet ACL, så vi kan matche både kilde og destination).
- `permit ip` = det er IP-trafik der skal krypteres (ikke "tillades" i firewall-forstand —
  her betyder `permit` "kryptér denne trafik").
- `192.168.1.0 0.0.0.255` = **kilde** (R1's LAN). `0.0.0.255` er wildcard-masken (det
  omvendte af `255.255.255.0`).
- `192.168.3.0 0.0.0.255` = **destination** (R3's LAN).
- Alt andet end det ACL'en matcher, sendes ukrypteret (implicit deny → ingen kryptering).
- På R3 skal ACL'en være **spejlvendt**: kilde `192.168.3.0`, destination `192.168.1.0`.

---

## 3. IKE Phase 1 — ISAKMP-policy

Phase 1 = de to routere autentificerer hinanden og bygger en sikker kanal til at aftale
resten.

```cisco
crypto isakmp policy 10
```
Går ind i Phase 1-politik nr. `10`. Nummeret er en **prioritet** — har man flere politikker,
prøves de laveste numre først, og den lavest-nummererede der matcher modparten vinder.
Politikken skal matche på begge routere.

```cisco
 encryption aes 256
```
Hvilken kryptering der beskytter **selve Phase 1-forhandlingen** (ikke brugertrafikken).
AES med 256-bit nøgle. (Default er `des` — derfor skal denne linje skrives.)

```cisco
 hash sha
```
Hash/integritets-algoritme til Phase 1 (tjekker at forhandlings-beskederne ikke er ændret).
`sha` er default, så linjen kan udelades.

```cisco
 authentication pre-share
```
Hvordan de to routere beviser hvem de er. `pre-share` = de deler en fælles hemmelig nøgle
(alternativet er `rsa-sig` med certifikater). Default er `rsa-sig`, så denne skal skrives.

```cisco
 group 5
```
Diffie-Hellman-gruppe. DH bruges til at **udveksle nøglerne sikkert**. Højere gruppe =
stærkere, men tungere. Packet Tracer understøtter maks. `5` (i produktion mindst 24).
Default er `1`, så denne skal skrives.

```cisco
 lifetime 86400
```
Hvor længe Phase 1-forbindelsen (ISAKMP SA) gælder før den skal genforhandles, i sekunder.
`86400` = 24 timer og er default, så linjen kan udelades.

```cisco
crypto isakmp key vpnpa55 address 10.2.2.2
```
Den fælles hemmelige nøgle (`vpnpa55`) — **bundet til modpartens IP** (`10.2.2.2` = R3's
serial-interface, den anden ende af tunnelen). Samme nøgle skal stå på R3, bundet til R1's
IP (`10.1.1.2`).

---

## 4. IKE Phase 2 — transform-set + crypto map

Phase 2 = de bliver enige om hvordan **den rigtige trafik** beskyttes.

```cisco
crypto ipsec transform-set VPN-SET esp-aes esp-sha-hmac
```
Laver et "transform-set" med et navn (`VPN-SET`) og de algoritmer der beskytter data:

- `esp-aes` = ESP med AES til **kryptering** af data.
- `esp-sha-hmac` = ESP med SHA-HMAC til **integritet/autentificering** af hver pakke.

```cisco
crypto map VPN-MAP 10 ipsec-isakmp
```
Laver et crypto map — den "samlekasse" der binder Phase 2 sammen.

- `VPN-MAP` = navn. `10` = sekvensnummer (kan have flere entries i samme map).
- `ipsec-isakmp` = brug IKE/ISAKMP til at forhandle tunnelen automatisk (i stedet for at
  sætte nøgler manuelt).

```cisco
 description VPN connection to R3
```
Bare en tekst-note på map-entryen.

```cisco
 set peer 10.2.2.2
```
Hvem den anden ende af tunnelen er — modpartens **offentlige/ydre IP** (`10.2.2.2`). På R3
peger den på R1 (`10.1.1.2`). **Ikke** R2's adresser.

```cisco
 set transform-set VPN-SET
```
Hvilket transform-set (fra ovenfor) der skal bruges til at beskytte trafikken.

```cisco
 match address 110
```
Hvilken ACL der bestemmer den **interessante trafik** — altså hvad der skal i tunnelen. Peger
på `access-list 110`.

---

## 5. Sæt crypto map på interfacet

```cisco
interface s0/0/0
 crypto map VPN-MAP
```
Aktiverer crypto map'et på det **udgående interface** mod internettet/R2. Først her træder
VPN'en i kraft. På R1 er det `S0/0/0`, på R3 er det `S0/0/1` (interfacet der vender mod R2).
Du får beskeden `ISAKMP is ON`.

---

## 6. Verificering — `show`-kommandoer

```cisco
show access-lists 110
```
Tjek at ACL'en ser rigtig ud. Match-tælleren er 0 indtil der har været trafik.

```cisco
show crypto isakmp sa
```
Phase 1-status. Vil se én linje mellem de to peers med state **`QM_IDLE`** når Phase 1 er
oppe.

```cisco
show crypto ipsec sa
```
Phase 2-status. Kig på tællerne:

- `#pkts encaps / encrypt` og `#pkts decaps / decrypt` = **0** før der er sendt interessant
  trafik.
- Efter en ping fra PC-A til PC-C: begge tællere **> 0 og stigende** = tunnelen virker.
- Ping fra PC-A til PC-B (ikke i ACL 110): tællerne **ændrer sig ikke** = kun interessant
  trafik krypteres.

```cisco
show crypto map
```
Viser map'ets peer, transform-set, match-ACL, og hvilket interface det er sat på.

> Ping fra selve routeren tæller ikke som interessant trafik (afsenderen bliver routerens
> egen serial-IP, ikke `192.168.1.0/24`). Test altid fra **PC-A til PC-C**.

---

## Kort: hvad hører til hvilken fase

| Kommando | Fase |
|---|---|
| `access-list 110 …` | interessant trafik (bruges af Phase 2) |
| `crypto isakmp policy` + `encryption` / `hash` / `authentication` / `group` / `lifetime` | **Phase 1** |
| `crypto isakmp key … address …` | **Phase 1** (autentificering) |
| `crypto ipsec transform-set …` | **Phase 2** |
| `crypto map … ipsec-isakmp` + `set peer` / `set transform-set` / `match address` | **Phase 2** |
| `interface …` + `crypto map` | aktiverer det hele |
