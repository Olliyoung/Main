---
tags: [network-2, cisco, packet-tracer, vlan, router-on-a-stick, dhcp, ospf, nat, opgave]
aliases: ["Byg netværket", "Comprehensive opgave", "VLAN RoaS DHCP OSPF NAT"]
---

# 10 — Byg netværket: VLAN · RoaS · static · DHCP · OSPF · NAT

> Følger opgavens 9 punkter. Under hvert step: hvad der skal gøres + hvilke kommandoer +
> hvad de gør. Kommando-detaljer i [[00 - Cheat sheet|Network 1/Cisco commands]],
> [[03 - OSPF]], [[04 - NAT and PAT]], [[05 - ACL]]. Skriv selv konfigurationen.

## Indhold

- [[#Topologi og adresser]]
- [[#Step 1 — Byg Lag 1]] · [[#Step 2 — Lag 2 (VLAN, porte, blackhole)]] · [[#Step 3 — Trunk mod routeren]]
- [[#Step 4 — Lag 3 router-on-a-stick]] · [[#Step 5 — Statiske ruter + Gateway of Last Resort]]
- [[#Step 6 — DHCP + ip helper]] · [[#Step 7 — OSPF]] · [[#Step 8 — NAT + ACL]] · [[#Step 9 — Test NAT]]

---

## Topologi og adresser

| VLAN | Navn | Net | Default gateway |
|---|---|---|---|
| 10 | HR | 192.168.10.0/24 | 192.168.10.1 |
| 20 | IT | 192.168.20.0/24 | 192.168.20.1 |
| 30 | Teacher | 192.168.30.0/24 | 192.168.30.1 |
| 40 | Student | 192.168.40.0/24 | 192.168.40.1 |
| 99 | native (mgmt) | 192.168.99.0/24 | — |
| 666 | blackhole | — | — |

| Link | Net |
|---|---|
| R1 ↔ R2 | 10.10.10.0/24 (R1 = .1, R2 = .2) |
| Router ↔ ISP | 200.2.2.0/24 (ISP-server = 200.2.2.2) |
| DHCP-server | 192.168.10.2/24 (ligger i VLAN 10) |

- **R1** (venstre): RoaS for VLAN 10 + 20 · link til R2 · link til ISP-serveren.
- **R2** (højre): RoaS for VLAN 30 + 40 · link til R1.

> [!warning] Hvilken router hedder hvad?
> Opgave-punkt 8 siger "NAT på Router2 ud mod ISP-serveren", men på tegningen sidder
> ISP-serveren på den **venstre** router. NAT + ACL skal ligge på **den router der har
> interfacet mod ISP-serveren** — kald den konsekvent det samme hele vejen igennem.

---

## Step 1 — Byg Lag 1

Placér enheder og kabler præcis som på tegningen (rigtige porte: Gig0/0, Gig0/1, Gig0/2,
Fa0/2, Fa0/3, Fa0/4, Fa0/10 …). **GEM en version** (File → Save As).

---

## Step 2 — Lag 2 (VLAN, porte, blackhole)

### 2a. Opret VLAN'erne

```cisco
vlan 10
 name HR
vlan 20
 name IT
vlan 30
 name Teacher
vlan 40
 name Student
vlan 99
 name vlan-99-native
vlan 666
 name vlan-666-blackhole
exit
```

> [!bug] Fejl i dit nuværende script
> Du mangler linjen **`vlan 99`** før `name vlan-99-native`. Uden den bliver
> `name vlan-99-native` sat på **VLAN 40** (den sidst indtastede) — så VLAN 40 hedder nu
> "vlan-99-native". Tilføj `vlan 99` og kør `name` igen.

### 2b. Luk ubrugte porte (blackhole)

Find de porte der **ikke** er i brug (`show interfaces status` → `notconnect`), og:

```cisco
interface range <de ubrugte porte>
 switchport mode access
 switchport access vlan 666
 shutdown
exit
```

- `switchport access vlan 666` = flyt porten til blackhole-VLAN'et.
- `shutdown` = sluk den. Blackhole-VLAN'et har ingen SVI og ingen route ud → en der
  patcher sig ind får ingenting.

### 2c. Læg de brugte porte i deres VLAN

```cisco
interface FastEthernet0/2
 switchport mode access
 switchport access vlan 10
exit
! … tilsvarende: PC2 → vlan 20, PC3 → vlan 30, PC4 → vlan 40,
!    DHCP-server (Fa0/10 på venstre switch) → vlan 10
```

### 2d. Management-SVI (kun ÉN på en 2960)

```cisco
interface vlan 99
 ip address 192.168.99.x 255.255.255.0
 no shutdown
exit
ip default-gateway 192.168.99.1
```

> [!bug] Fejl i dit nuværende script
> - Du har lavet **`interface vlan 10/20/30/40`** på switchen. Det skal du **ikke** — en
>   Layer 2-switch (2960) kan kun have **én** aktiv SVI, og inter-VLAN-routing sker på
>   **routeren** (Step 4), ikke på switchen. Fjern SVI'erne for 10/20/30/40 og for 666.
> - **`encapsulation dot1Q 99 native` under `interface vlan 99` er ugyldigt.** Den kommando
>   hører til et **router-subinterface**. Den native VLAN sættes på **trunk-porten** (Step 3)
>   med `switchport trunk native vlan 99`.

**GEM.**

---

## Step 3 — Trunk mod routeren

På porten (Gig0/1) der går op til routeren:

```cisco
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk native vlan 99
 switchport trunk allowed vlan 10,20,99      ! venstre switch: 10,20 · højre switch: 30,40
exit
```

- `switchport mode trunk` = tving trunk (ikke DTP-forhandling).
- `switchport trunk native vlan 99` = utagget trafik hører til VLAN 99. Skal matche på
  routerens native-subinterface.
- `switchport trunk allowed vlan …` = kun de VLAN switchen faktisk bruger. (Se
  `add`-faldgruben i [[01 - Layer 2 foundation]] hvis trunk'en allerede findes.)

Verificér: `show interfaces trunk` → native VLAN 99, allowed = dine VLAN. **GEM.**

---

## Step 4 — Lag 3 router-on-a-stick

På **R1** (VLAN 10 + 20) — tilsvarende på **R2** for VLAN 30 + 40.

```cisco
interface GigabitEthernet0/1
 no shutdown
exit
interface GigabitEthernet0/1.10
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.0
exit
interface GigabitEthernet0/1.20
 encapsulation dot1Q 20
 ip address 192.168.20.1 255.255.255.0
exit
interface GigabitEthernet0/1.99
 encapsulation dot1Q 99 native
 ip address 192.168.99.1 255.255.255.0
exit
```

- Fysisk `Gig0/1` **`no shutdown`** først — ellers er alle subinterfaces nede.
- `encapsulation dot1Q <vlan>` = subinterfacet håndterer den VLAN's taggede trafik.
- Subinterfacet for native VLAN får `… 99 native`.
- IP'en på subinterfacet = default gateway for den VLAN's PC'er.

Sæt også IP på R1↔R2-linket (`Gig0/0` = 10.10.10.1) og R1↔ISP (`Gig0/2` = 200.2.2.1).

**Test:** ping mellem to VLAN på samme router (fx PC1 VLAN 10 → PC2 VLAN 20). Virker det →
RoaS kører. **GEM.**

---

## Step 5 — Statiske ruter + Gateway of Last Resort

Hver router kender kun sine **direkte forbundne** net. Resten skal du fortælle den.

```cisco
! R1: hvordan når jeg VLAN 30 og 40? -> via R2
ip route 192.168.30.0 255.255.255.0 10.10.10.2
ip route 192.168.40.0 255.255.255.0 10.10.10.2
! R1: alt ukendt (internettet) -> ud mod ISP = Gateway of Last Resort
ip route 0.0.0.0 0.0.0.0 200.2.2.2

! R2: hvordan når jeg VLAN 10, 20 og ISP-nettet? -> via R1
ip route 192.168.10.0 255.255.255.0 10.10.10.1
ip route 192.168.20.0 255.255.255.0 10.10.10.1
! R2: alt ukendt -> via R1 = Gateway of Last Resort
ip route 0.0.0.0 0.0.0.0 10.10.10.1
```

- `ip route <net> <mask> <next-hop>` = statisk rute.
- `ip route 0.0.0.0 0.0.0.0 <next-hop>` = default-rute. `show ip route` viser den som
  "Gateway of last resort is … to network 0.0.0.0".

**Test:** ping VLAN 10 → VLAN 40, og ping ISP-serveren `200.2.2.2` fra en PC. **GEM.**

---

## Step 6 — DHCP + ip helper

DHCP-serveren (192.168.10.2) ligger i **VLAN 10**. PC'er i andre VLAN kan ikke selv nå den
med broadcast — routeren skal videresende.

På **hvert subinterface undtagen VLAN 10**:

```cisco
interface GigabitEthernet0/1.20
 ip helper-address 192.168.10.2
! tilsvarende på .30 og .40 (på den router de sidder på)
```

- `ip helper-address <dhcp-server>` = router omdanner klientens DHCP-broadcast til unicast
  mod serveren. VLAN 10 behøver det ikke (serveren er lokalt på VLAN 10).

På **DHCP-serveren** (Server Config → DHCP): én pool pr. VLAN med
- Default Gateway = subinterfacets IP (fx `192.168.20.1`)
- DNS Server = `8.8.8.8`
- Start-IP + subnet mask for det net

**Test:** hver PC på "DHCP" → får IP, gateway og DNS 8.8.8.8. **GEM.**

---

## Step 7 — OSPF

Erstat de statiske ruter mellem R1 og R2 med OSPF (behold default-ruten mod ISP på R1).

```cisco
! R1
router ospf 1
 network 192.168.10.0 0.0.0.255 area 0
 network 192.168.20.0 0.0.0.255 area 0
 network 10.10.10.0 0.0.0.255 area 0
 default-information originate      ! del R1's default-rute (mod ISP) ud til R2
! R2
router ospf 1
 network 192.168.30.0 0.0.0.255 area 0
 network 192.168.40.0 0.0.0.255 area 0
 network 10.10.10.0 0.0.0.255 area 0
```

- `network <net> <wildcard> area 0` = slå OSPF til på de interfaces der matcher. Wildcard =
  det omvendte af subnetmasken.
- `default-information originate` = R1 annoncerer sin **Gateway of Last Resort** i OSPF, så
  R2 (og resten) lærer vejen til internettet. Uden den har R2 ingen default-rute.
- Detaljer + verificering: [[03 - OSPF]].

**Test:** `show ip ospf neighbor` (state `FULL`), `show ip route ospf` (`O` + `O*E2` for
default).

---

## Step 8 — NAT + ACL

På routeren mod ISP-serveren. VLAN 20 og 40 **må ikke** kunne nå ISP-serveren.

```cisco
! marker interfaces
interface GigabitEthernet0/1.10
 ip nat inside
! (samme ip nat inside på alle inside-subinterfaces)
interface GigabitEthernet0/2
 ip nat outside
!
! ACL: hvilke net MÅ oversættes (og dermed nå ISP) — VLAN 20 og 40 er IKKE med
ip access-list standard NAT-TILLADT
 permit 192.168.10.0 0.0.0.255
 permit 192.168.30.0 0.0.0.255
!
! PAT: oversæt det ACL'en tillader, gem bag ISP-interfacets IP
ip nat inside source list NAT-TILLADT interface GigabitEthernet0/2 overload
```

- `ip nat inside` / `ip nat outside` = hvilken side er privat / offentlig.
- Standard-ACL'en **udvælger** hvem der bliver oversat. Da VLAN 20 og 40 ikke er `permit`,
  bliver de ikke oversat → deres private adresser kan ikke routes videre til ISP → de kan
  ikke nå `200.2.2.2`. (Den implicitte `deny` klarer resten.)
- `… overload` = PAT, mange hosts bag én adresse (port-numre skiller dem ad).
- Detaljer: [[04 - NAT and PAT]] · [[05 - ACL]].

**GEM.**

---

## Step 9 — Test NAT

Fra en PC i **VLAN 10 eller 30**: `ping 200.2.2.2` (skal virke).
Fra en PC i **VLAN 20 eller 40**: `ping 200.2.2.2` (skal **fejle** — de er ikke i ACL'en).

På routeren:
```cisco
show ip nat translations      ! se private -> 200.2.2.1 oversættelser med portnumre
show ip nat statistics        ! Hits stiger, inside/outside interfaces listet
show access-lists             ! match-tæller på permit-linjerne
```

---

## Rækkefølge til at gemme (opgaven beder om det flere gange)

Lag 1 → **GEM** → Lag 2 + trunk → **GEM** → RoaS + ping mellem VLAN → **GEM** →
statiske ruter + ping VLAN10↔VLAN40 + ISP → **GEM** → DHCP → **GEM** → OSPF →
NAT → **GEM**.
