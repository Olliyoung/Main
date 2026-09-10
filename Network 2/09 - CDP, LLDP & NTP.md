---
tags: [network-2, cisco, cdp, lldp, ntp, discovery, kommandoer, opgave]
aliases: ["CDP LLDP NTP", "Configure CDP, LLDP, and NTP", "Discovery protocols"]
---
 
# 09 — CDP, LLDP & NTP: kommandoer forklaret (pr. step)

> Følger opgavens opbygning: **Del 0 (find IP'er)**, **Del 1 (LLDP på HQ-siden)**,
> **Del 2 (CDP på Branch-siden)**, **Del 3 (NTP)**.
> Under hvert step: kommandoen + hvad den gør. Skriv afleveringen med dine egne ord.

## Indhold

- [[#Reference — enheder og login]]
- [[#Baggrund — hvad er CDP, LLDP og NTP]]
- [[#Del 0 — Find de ukendte IP-adresser]]
- [[#Del 1 — LLDP på HQ-siden]] · Step 1 · 2 · 3 · 4 · 5 · 6 · 7
- [[#Del 2 — CDP på Branch-siden]] · Step 1 · 2 · 3
- [[#Del 3 — NTP på HQ]] · Step 1
- [[#Verificering]] · [[#Hvis noget ikke virker]]
- [[#⚠️ Fejl vi ramte i denne lab]] · [[#Alle kommandoer vi brugte]]

---

## Reference — enheder og login

### Kendte adresser

| Enhed | Interface | IP |
|---|---|---|
| HQ | G0/0/0 | 192.168.1.1/24 |
| HQ | G0/0/1 | 192.168.2.1/24 |
| HQ | S0/1/0 | 192.168.3.1/30 |
| Branch | G0/0/0 | 192.168.1.2 |
| Branch | S0/1/0 | 192.168.3.2/30 |
| NTP Server | NIC | 192.168.1.254 |
| PC1 / PC2 / PC3 | NIC | 192.168.2.10 / 192.168.4.10 / 192.168.4.20 |

**Ukendte (find dem selv i Del 0):** HQ-SW-1, HQ-SW-2 (VLAN 1) · BR-SW-1, BR-SW-2, BR-SW-3 (VLAN 10).

### SSH-login til Branch-switchene

| Enhed | Username | Password | Enable secret |
|---|---|---|---|
| BR-SW1 | admin | `SW1admin#` | `SW1EnaAccess#` |
| BR-SW2 | admin | `SW2admin#` | `SW2EnaAccess#` |
| BR-SW3 | admin | `SW3admin#` | `SW3EnaAccess#` |

> Du kan **ikke** åbne CLI ved at klikke på Branch-switchene — du skal SSH'e ind.

---

## Baggrund — hvad er CDP, LLDP og NTP

- **CDP (Cisco Discovery Protocol)** — Cisco-only. Enheder annoncerer sig selv til direkte
  naboer (navn, model, IOS, IP, port). Praktisk til at kortlægge et ukendt netværk, men
  **lækker topologi-info** → slå det fra hvor det ikke er nødvendigt (fx mod ikke-Cisco
  eller mod slutbrugere).
- **LLDP (Link Layer Discovery Protocol, IEEE 802.1AB)** — åben standard, samme formål som
  CDP, virker på tværs af producenter. **Send og modtag styres hver for sig** pr. interface
  (`transmit` / `receive`).
- **NTP (Network Time Protocol)** — synkroniserer enhedens ur fra en tidsserver. Vigtigt for
  korrekte timestamps i logs, certifikater osv. **Stratum** = afstand til den præcise
  kilde (lavere = tættere på).

---

## Del 0 — Find de ukendte IP-adresser

Nogle switch-IP'er kender du ikke. Brug discovery-protokollen på routeren til at læse dem,
og skriv dem ind i tabellen.

```cisco
! Cisco-naboer med detaljer (viser Device ID, IP-adresse, lokal + remote port, model, IOS)
show cdp neighbors detail
! samme for LLDP
show lldp neighbors detail
! kort oversigt
show cdp neighbors
show lldp neighbors
```

- Kør på **HQ** for at finde HQ-SW-1 / HQ-SW-2, og på **Branch** for BR-SW-1/2/3.
- Kolonnen "IP address" / "Management address" i `... detail` er den du SSH'er til.
- Naboer opdateres kun periodisk → tryk **Fast Forward Time** et par gange hvis listen er tom.

---

## Del 1 — LLDP på HQ-siden

### Step 1 — Slå CDP fra på HQ

```cisco
no cdp run
```
`cdp run` / `no cdp run` = **global** til/fra for hele enheden. `no` slår CDP helt fra på HQ.

### Step 2 — Slå LLDP til globalt på HQ

```cisco
lldp run
```
`lldp run` = global til for LLDP. (LLDP er som udgangspunkt slået fra på Cisco.)

### Step 3 — HQ's links mod switchene: kun MODTAG LLDP

På hvert interface der vender mod HQ-SW-1 / HQ-SW-2:

```cisco
interface <interface mod switchen>
 lldp receive
 no lldp transmit
```

- `lldp receive` = interfacet **modtager** naboinfo.
- `no lldp transmit` = interfacet **sender ikke** info om HQ ud.
- "Only receive" = receive **til**, transmit **fra**.
- Find det rigtige interface med `show lldp neighbors` / `show cdp neighbors` (hvilken HQ-port
  sidder switchen på).

### Step 4 — Slå CDP fra på HQ-SW-1 og HQ-SW-2

På hver af de to switche:
```cisco
no cdp run
```

### Step 5 — Slå LLDP til på HQ-SW-1 og HQ-SW-2

```cisco
lldp run
```

### Step 6 — Switchenes link mod HQ: kun SEND LLDP

På porten der vender op mod HQ-routeren (på hver switch):
```cisco
interface <port mod HQ>
 lldp transmit
 no lldp receive
```
- "Only send, not receive" = transmit **til**, receive **fra**. Modsat af Step 3.

### Step 7 — Slå LLDP helt fra på de brugte access-porte (HQ-SW-1 / HQ-SW-2)

Find hvilke porte der er i brug:
```cisco
show interfaces status        ! "connected" = i brug
```
På hver **brugt access-port**:
```cisco
interface range <de brugte porte>
 no lldp transmit
 no lldp receive
```
- Begge fra = LLDP helt slået fra på porten (ingen info mod slutbrugere).

---

## Del 2 — CDP på Branch-siden

### Step 1 — Aktivér CDP på Branch-routeren

```cisco
cdp run
```
Slår CDP til globalt på Branch (så du kan opdage BR-switchene).

### Step 2 — SSH til BR-SW1

1. Find BR-SW1's IP fra Branch: `show cdp neighbors detail`.
2. SSH ind (fra en PC eller fra routeren):
   ```cisco
   ssh -l admin <BR-SW1-ip>
   ```
   Password `SW1admin#`, derefter `enable` med secret `SW1EnaAccess#`.
3. Opgaven beder dig kun **forbinde** til BR-SW1 her (discovery). BR-SW2/BR-SW3 skal
   konfigureres i Step 3.

### Step 3 — BR-SW2 og BR-SW3: brugte access-porte skal ikke sende CDP

SSH ind på hver (samme fremgang, password `SW2admin#` / `SW3admin#`, secret
`SW2EnaAccess#` / `SW3EnaAccess#`).

Find de brugte porte:
```cisco
show interfaces status        ! "connected"
show cdp interface            ! hvilke porte kører CDP
```
På hver **brugt access-port**:
```cisco
interface range <de brugte porte>
 no cdp enable
```
- `cdp enable` / `no cdp enable` = CDP til/fra **pr. interface** (CDP kører stadig globalt).
- `no cdp enable` = porten sender/modtager ikke CDP → naboinfo lækker ikke ud til det der
  sidder på access-porten.

---

## Del 3 — NTP på HQ

### Step 1 — Peg HQ på NTP-serveren

```cisco
ntp server 192.168.1.254
```
Fortæller HQ at den skal hente tid fra `192.168.1.254`. Routeren begynder at synkronisere.

Verificér:
```cisco
show ntp status          ! "Clock is synchronized", reference = 192.168.1.254, stratum
show ntp associations    ! serveren står med et "*" når den er valgt som kilde
```
Synk tager lidt tid → tryk **Fast Forward Time**.

---

## Verificering

```cisco
! CDP
show cdp                       ! global: kører CDP? interval?
show cdp interface             ! pr. interface: kører CDP her?
show cdp neighbors detail      ! opdagede Cisco-naboer + deres IP
! LLDP
show lldp                      ! global status
show lldp interface            ! pr. interface: Tx/Rx enabled?
show lldp neighbors detail     ! opdagede naboer (også ikke-Cisco)
! NTP
show ntp status
show ntp associations
```

Forventet efter opgaven:
- HQ: `show cdp` siger CDP er **ikke** aktivt; `show lldp interface` viser links mod
  switchene som **Rx: enabled, Tx: disabled**.
- HQ-SW-1/2: links mod HQ som **Tx: enabled, Rx: disabled**; brugte access-porte som
  **Tx og Rx disabled**.
- Branch: `show cdp` aktivt; BR-SW2/3 brugte access-porte uden CDP (`show cdp interface`).
- HQ: `show ntp status` = synchronized til `192.168.1.254`.

## Hvis noget ikke virker

| Symptom | Tjek |
|---|---|
| `show ... neighbors` er tom | vent / tryk **Fast Forward Time** flere gange; er protokollen slået til globalt **og** på interfacet? |
| Kan ikke SSH'e til en BR-switch | fandt du den rigtige IP i `show cdp neighbors detail`? er der IP-forbindelse til VLAN 10-netværket? |
| "only receive" virker ikke | `lldp receive` **og** `no lldp transmit` skal begge sættes — det er to separate kommandoer |
| CDP stadig på en access-port | `no cdp enable` sættes **pr. interface**; `no cdp run` er global og en anden ting |
| NTP synkroniserer ikke | rigtig server-IP? rute til `192.168.1.254`? giv det tid + Fast Forward; `show ntp associations` |
| Ved ikke hvilke porte der er "i brug" | `show interfaces status` → `connected` |

---

## ⚠️ Fejl vi ramte i denne lab

> [!warning]
> - **Router-interface-navne på en switch.** `interface GigabitEthernet0/0/0` / `0/0/1` er
>   *routerens* porte og findes ikke på en switch → `% Invalid input`. På switchene hedder
>   portene fx `FastEthernet0/1` eller `GigabitEthernet0/1`. Bemærk: `no cdp run` og
>   `lldp run` gik igennem og **skal beholdes** — det er kun interface-linjerne der fejlede.
> - **Antog at HQ-SW-2's porte matcher HQ-SW-1's.** Det gør de ikke nødvendigvis — tjek
>   `show interfaces status` og `show lldp neighbors` på **hver switch for sig**.
> - **`no cdp run` "hang ikke ved".** Den virker kun fra `(config)#` — ikke fra
>   `(config-if)#` eller almindelig `#`. Var du i interface-mode → `exit` først. Bagefter
>   `show cdp` = "CDP is not enabled".
> - **Pladsholdere kopieret bogstaveligt.** `<porten mod HQ>` skal erstattes med det rigtige
>   portnavn før du trykker enter.
> - **Glemte at gemme.** `write memory` så config'en overlever en reload.

---

## Alle kommandoer vi brugte

### Discovery (kør FØR du slår protokoller fra)

```cisco
show cdp neighbors
show cdp neighbors detail      ! Device ID + IP + lokal/remote port
show lldp neighbors
show lldp neighbors detail
show interfaces status         ! "connected" = porten er i brug
show cdp interface             ! hvilke porte kører CDP
show lldp interface            ! Tx/Rx pr. port
```

### HQ (router) — LLDP-siden

```cisco
enable
configure terminal
no cdp run
lldp run
interface <link mod HQ-SW-1>
 lldp receive
 no lldp transmit
exit
interface <link mod HQ-SW-2>
 lldp receive
 no lldp transmit
exit
end
write memory
```

### HQ-SW-1 og HQ-SW-2 (SSH ind — samme på begge)

```cisco
enable
configure terminal
no cdp run
lldp run
interface <port mod HQ-routeren>
 lldp transmit
 no lldp receive
exit
interface range <brugte access-porte>
 no lldp transmit
 no lldp receive
exit
end
write memory
```

### Branch (router) — CDP-siden

```cisco
enable
configure terminal
cdp run
end
show cdp neighbors detail      ! find BR-SW-1/2/3's IP-adresser
ssh -l admin <BR-SW-ip>        ! login: SWxadmin#  /  enable: SWxEnaAccess#
```

### BR-SW2 og BR-SW3 (SSH ind)

```cisco
enable
show interfaces status
show cdp interface
configure terminal
interface range <brugte access-porte>
 no cdp enable
exit
end
write memory
```

### HQ — NTP

```cisco
enable
configure terminal
ntp server 192.168.1.254
end
```

### Tjek til sidst (efter 100 %)

```cisco
! HQ
show lldp neighbors
show ntp status               ! "Clock is synchronized", stratum, reference 192.168.1.254
show ntp associations         ! kilden markeret med *
show clock
! HQ-SW-1 / HQ-SW-2
show cdp                      ! "CDP is not enabled"
show lldp interface           ! link mod HQ: Tx on / Rx off ; access-porte: begge off
! Branch
show cdp neighbors detail
! BR-SW2 / BR-SW3
show cdp interface            ! de brugte access-porte skal IKKE stå på listen
```
