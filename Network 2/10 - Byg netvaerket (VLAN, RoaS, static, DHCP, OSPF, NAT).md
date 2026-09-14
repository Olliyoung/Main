---
tags: [network-2, cisco, packet-tracer, vlan, router-on-a-stick, dhcp, ospf, nat, opgave]
aliases: ["Byg netværket", "Comprehensive opgave", "VLAN RoaS DHCP OSPF NAT"]
---

# 10 — Byg netværket: VLAN · RoaS · static · DHCP · OSPF · NAT

> Følger opgavens 9 punkter, opdateret med det vi faktisk ramte og rettede undervejs. Under
> hvert step: hvad der skal gøres, kommandoerne, og hvad de gør. Brug det til at forstå og
> genskabe det — ikke til blindt at kopiere.
> Kommando-detaljer i [[00 - Cheat sheet|Network 1/Cisco commands]], [[01 - Layer 2 foundation]],
> [[03 - OSPF]], [[04 - NAT and PAT]], [[05 - ACL]].

## Indhold

- [[#Topologi og adresser]]
- [[#Step 1 — Byg Lag 1]] · [[#Step 2 — Lag 2 (VLAN, porte, blackhole)]] · [[#Step 3 — Trunk mod routeren]]
- [[#Step 4 — Lag 3 router-on-a-stick]] · [[#Step 5 — Statiske ruter + Gateway of Last Resort]]
- [[#Step 6 — DHCP + ip helper]] · [[#Step 7 — OSPF]] · [[#Step 8 — NAT + ACL]] · [[#Step 9 — Test NAT]]
- [[#⚠️ Fejl vi ramte i denne opgave]] · [[#🧭 Diagnostik-rækkefølge der virkede]]

---

## Topologi og adresser

| VLAN | Navn | Net | Default gateway |
|---|---|---|---|
| 10 | HR | 192.168.10.0/24 | 192.168.10.1 |
| 20 | IT | 192.168.20.0/24 | 192.168.20.1 |
| 30 | Teacher | 192.168.30.0/24 | 192.168.30.1 |
| 40 | Student | 192.168.40.0/24 | 192.168.40.1 |
| 99 | native (mgmt) | 192.168.99.0/24 | (pr. side — se note nedenfor) |
| 666 | blackhole | — | — |

| Link | Net |
|---|---|
| Router-2 ↔ Router-1 | 10.10.10.0/24 (Router-2 = `10.10.10.1`, Router-1 = `10.10.10.2`) |
| Router-2 ↔ ISP-server | 200.2.2.0/24 (Router-2 `Gig0/2` = `200.2.2.1`, ISP-server = `200.2.2.2`) |
| DHCP-server | 192.168.10.2/24 (ligger i VLAN 10) |

> [!important] Hvem er hvem (den her forvirrede os hele vejen igennem)
> - **Router-2** = **venstre** router. Har VLAN 10 + 20 (RoaS) **og** ISP-linket (`Gig0/2`).
> - **Router-1** = **højre** router. Har VLAN 30 + 40 (RoaS). Intet ISP-link.
> - Al **NAT og ACL mod ISP'en ligger på Router-2** — ikke Router-1, selvom opgaveteksten
>   isoleret set nævner "Router2" uden at det nødvendigvis matcher jeres hostnames.

### VLAN 99 — to adskilte segmenter

Hver switch har sit eget VLAN 99 (ingen trunk mellem de to switche), så det er reelt to
separate netværk der bare deler nummer:
- Venstre switch's mgmt-gateway = Router-2's `Gig0/1.99`
- Højre switch's mgmt-gateway = Router-1's `Gig0/1.99`

Brug **forskellige** IP'er hvis du vil undgå forvirring (fx `.1` på Router-2, `.2` på
Router-1), og sørg for at hver switch's `ip default-gateway` peger på **sin egen** router.

> [!warning] Verificér interface-navne
> `show ip interface brief` først. Vores routere er CISCO2911 → `GigabitEthernet0/0–0/2`.

---

## Step 1 — Byg Lag 1

Placér enheder og kabler præcis som på tegningen. **GEM en version** (File → Save As).

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

### 2b. Luk ubrugte porte (blackhole)

```cisco
interface range <de ubrugte porte>
 switchport mode access
 switchport access vlan 666
 shutdown
exit
```

### 2c. Læg de brugte porte i deres VLAN

```cisco
interface FastEthernet0/2
 switchport mode access
 switchport access vlan 10
exit
! tilsvarende: DHCP-server -> vlan 10, PC2 -> vlan 20 (venstre switch)
!              PC3 -> vlan 30, PC4 -> vlan 40 (højre switch)
```

### 2d. Management-SVI (kun ÉN på en 2960)

```cisco
interface vlan 99
 ip address 192.168.99.x 255.255.255.0
 no shutdown
exit
ip default-gateway 192.168.99.x   ! den ROUTER-IP der hører til DENNE switch
```

**GEM.**

---

## Step 3 — Trunk mod routeren

```cisco
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk native vlan 99
 switchport trunk allowed vlan 10,20,99      ! venstre switch: 10,20 · højre switch: 30,40
exit
```

Verificér: `show interfaces trunk` → native VLAN 99, allowed = dine VLAN. **GEM.**

---

## Step 4 — Lag 3 router-on-a-stick

**På Router-2** (VLAN 10 + 20):
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
Plus IP på R1↔R2-linket (`Gig0/0` = `10.10.10.1`) og mod ISP (`Gig0/2` = `200.2.2.1`).

**På Router-1** (VLAN 30 + 40) — samme opskrift, egne VLAN og egen IP på `.99`:
```cisco
interface GigabitEthernet0/1
 no shutdown
exit
interface GigabitEthernet0/1.30
 encapsulation dot1Q 30
 ip address 192.168.30.1 255.255.255.0
exit
interface GigabitEthernet0/1.40
 encapsulation dot1Q 40
 ip address 192.168.40.1 255.255.255.0
exit
interface GigabitEthernet0/1.99
 encapsulation dot1Q 99 native
 ip address 192.168.99.2 255.255.255.0
exit
```
Plus IP på R1↔R2-linket (`Gig0/0` = `10.10.10.2`).

> [!bug] Fejl vi ramte
> Vi kom til at lægge `.30`- og `.40`-subinterfaces **på Router-2 ved siden af** dem der
> allerede lå der (den skal kun have `.10`/`.20`/`.99`). Se konsekvensen under Step 5.

**Test:** ping mellem to VLAN på samme router (fx PC1 VLAN 10 → PC2 VLAN 20). **GEM.**

---

## Step 5 — Statiske ruter + Gateway of Last Resort

```cisco
! Router-2 (venstre, har ISP)
ip route 192.168.30.0 255.255.255.0 10.10.10.2
ip route 192.168.40.0 255.255.255.0 10.10.10.2
ip route 0.0.0.0 0.0.0.0 200.2.2.2      ! Gateway of Last Resort -> mod ISP

! Router-1 (højre)
ip route 192.168.10.0 255.255.255.0 10.10.10.1
ip route 192.168.20.0 255.255.255.0 10.10.10.1
ip route 0.0.0.0 0.0.0.0 10.10.10.1     ! Gateway of Last Resort -> mod Router-2
```

- Reglen: **hver routers default peger mod den der er tættest på internettet.** Router-2
  rører ISP direkte → dens default går til `200.2.2.2`. Router-1 skal igennem Router-2.
- `0.0.0.0 0.0.0.0 10.10.10.1` skal **aldrig** stå på Router-2 selv — det er dens egen IP.

> [!bug] Fejl vi ramte — forkerte subinterfaces slog statiske ruter ihjel
> Da Router-2 (fejlagtigt, se Step 4) havde `Gig0/1.30`/`.40`, troede den at
> `192.168.30.0/24` og `.40.0/24` var **direkte forbundet**. Direkte forbundet (`C`) vinder
> altid over en statisk rute (`S`) til samme net — så vores `ip route 192.168.30.0 … via
> 10.10.10.2` blev **ignoreret**, og trafik blev sendt forkert ud ad den venstre trunk i
> stedet. Løsning: `no interface GigabitEthernet0/1.30` / `.40` på Router-2.

> [!tip] `C` og `L` kan (og skal) ikke slettes
> Sletter du alle statiske ruter (`no ip route …`), er der stadig `C`/`L`-linjer tilbage i
> `show ip route` — det er routerens **egne, direkte forbundne** net. De kommer automatisk
> så snart et interface har en IP og er oppe. Det er normalt, ikke en fejl.

**Test:** ping VLAN 10 → VLAN 40, og ping ISP-serveren `200.2.2.2` fra en PC. **GEM.**

---

## Step 6 — DHCP + ip helper

> [!bug] Den vigtigste fejl i hele opgaven
> **DHCP virkede slet ikke — heller ikke for det lokale VLAN 10 — fordi DHCP-serverens
> EGEN netværkskort aldrig fik en IP-adresse.** Poolerne i DHCP-servicen var udfyldt
> korrekt, men uden en gyldig static IP/gateway på selve serverens NIC virker intet.
> **Gør dette FØRST, før du rører poolerne:**

### 6a. Konfigurér DHCP-serverens egen IP

På serveren → **Desktop → IP Configuration** (eller Config → interface):
- IP-adresse: `192.168.10.2`, mask `255.255.255.0`
- Default gateway: `192.168.10.1`
- (Skal være **Static**, ikke DHCP — den er jo selv serveren.)

### 6b. `ip helper-address` på routeren — på hvert subinterface UNDTAGEN VLAN 10

```cisco
interface GigabitEthernet0/1.20
 ip helper-address 192.168.10.2
! tilsvarende på .30 og .40 (på den router de sidder på)
```
- DHCP-serveren ligger i VLAN 10 → PC'er i andre VLAN kan ikke nå den med broadcast, så
  routeren skal videresende (unicast) i stedet. VLAN 10 selv behøver ikke det.

### 6c. DHCP-pools på serveren (Services → DHCP)

Én pool pr. VLAN:
- Default Gateway = det VLAN's subinterface-IP (fx `192.168.20.1`)
- DNS Server = `8.8.8.8`
- Start-IP i det net + `255.255.255.0`
- **Husk service-toggle'en øverst er sat til "On"** — pooler alene gør intet uden den.

**Test:** hver PC på "DHCP" → får IP, gateway og DNS `8.8.8.8`. **GEM.**

---

## Step 7 — OSPF

```cisco
! Router-2 (ISP-siden)
router ospf 1
 network 192.168.10.0 0.0.0.255 area 0
 network 192.168.20.0 0.0.0.255 area 0
 network 10.10.10.0 0.0.0.255 area 0
 default-information originate

! Router-1
router ospf 1
 network 192.168.30.0 0.0.0.255 area 0
 network 192.168.40.0 0.0.0.255 area 0
 network 10.10.10.0 0.0.0.255 area 0
```

- `default-information originate` = Router-2 **deler sin egen Gateway of Last Resort ud**
  til Router-1 via OSPF (vises som `O*E2 0.0.0.0/0` på Router-1).

### Ryd op i statiske ruter bagefter

Fjern det OSPF nu selv finder — **men behold ISP-default'en på Router-2**:

```cisco
! Router-2 - fjern, men IKKE default-ruten
no ip route 192.168.30.0 255.255.255.0 10.10.10.2
no ip route 192.168.40.0 255.255.255.0 10.10.10.2
! ip route 0.0.0.0 0.0.0.0 200.2.2.2  <- BLIVER STÅENDE, det er den der originates

! Router-1 - fjern alle tre, OSPF overtager dem
no ip route 192.168.10.0 255.255.255.0 10.10.10.1
no ip route 192.168.20.0 255.255.255.0 10.10.10.1
no ip route 0.0.0.0 0.0.0.0 10.10.10.1
```

> [!bug] Fejl vi ramte
> Vi havde en gammel `ip route 200.2.2.0 255.255.255.0 10.10.10.1` liggende på Router-1 —
> overflødig, fordi `O*E2 0.0.0.0/0` allerede dækker den. `no ip route 200.2.2.0
> 255.255.255.0 10.10.10.1` for at rydde op.

**Tjek:** `show ip ospf neighbor` (state `FULL`), `show ip route ospf`
(`O` for modpartens VLAN, `O*E2` for default på Router-1). Detaljer: [[03 - OSPF]].

---

## Step 8 — NAT + ACL

**Alt dette køres på Router-2** — det er den med `Gig0/2` mod ISP-serveren. Router-1 skal
ikke have noget NAT/ACL-config overhovedet.

### 8a. Marker inside/outside

```cisco
interface GigabitEthernet0/1.10
 ip nat inside
exit
interface GigabitEthernet0/1.20
 ip nat inside
exit
interface GigabitEthernet0/0
 ip nat inside          ! !! linket til Router-1 - VLAN 30's trafik kommer ind her !!
exit
interface GigabitEthernet0/2
 ip nat outside
exit
```

> [!bug] Fejl vi ramte
> Vi glemte først `ip nat inside` på **`Gig0/0`** (linket til Router-1). Uden den bliver
> VLAN 30's trafik, som ankommer via den port, aldrig genkendt som "inside" og bliver ikke
> oversat.

### 8b. NAT-udvælgelse — hvem MÅ oversættes (VLAN 20 og 40 er IKKE med)

```cisco
ip access-list standard NAT-TILLADT
 permit 192.168.10.0 0.0.0.255
 permit 192.168.30.0 0.0.0.255
exit

ip nat inside source list NAT-TILLADT interface GigabitEthernet0/2 overload
```

### 8c. Rigtig blokering — filter-ACL (NAT-listen alene er IKKE nok!)

> [!bug] Den store lærdom fra denne opgave
> `NAT-TILLADT` bestemmer kun **hvem der bliver oversat** — ikke hvem der bliver **rutet**.
> Router-2 kender stadig ruten til `192.168.20.0/24` og `.40.0/24` internt (via OSPF), så
> selv uoversat trafik blev **stadig rutet frem og tilbage**, fordi hele netværket er internt
> og selv-rutet — ikke som et rigtigt internet, hvor en modpart ikke ville kende vejen
> tilbage til en privat adresse. Resultat: alle PC'er kunne pinge ISP-serveren, selvom kun
> VLAN 10/30 stod i NAT-udvælgelsen.
>
> Løsning: en **rigtig filter-ACL**, sat udgående på `Gig0/2`, der aktivt dropper VLAN
> 20/40's trafik mod ISP-serveren:

```cisco
ip access-list extended BLOK-ISP
 deny ip 192.168.20.0 0.0.0.255 host 200.2.2.2
 deny ip 192.168.40.0 0.0.0.255 host 200.2.2.2
 permit ip any any
exit

interface GigabitEthernet0/2
 ip access-group BLOK-ISP out
exit
```

- `permit ip any any` i bunden er **kritisk** — uden den blokerer den implicitte deny **alt**
  ud af `Gig0/2`, inkl. VLAN 10/30's NAT'ede trafik.
- `out` på `Gig0/2` = tjekkes lige før pakken forlader routeren, uanset hvilket interface den
  kom ind ad (Gig0/1.20 lokalt, eller Gig0/0 fra Router-1 for VLAN 40).

> [!bug] To konkrete fejl vi ramte med filter-ACL'en
> 1. **Bundet, men aldrig oprettet.** `show ip interface GigabitEthernet0/2 | include
>    access list` viste `Outgoing access list is BLOK-ISP` — men `show access-lists
>    BLOK-ISP` viste **ingenting**. En navngivet ACL der er bundet til et interface men
>    **tom** filtrerer intet (opfører sig som "tillad alt"). Den var blevet slettet
>    (`no ip access-list extended BLOK-ISP`) og aldrig genskabt. Fix: opret den forfra.
> 2. **Ikke bundet til interfacet overhovedet.** `show ip interface GigabitEthernet0/2 |
>    include access list` viste `Outgoing access list is not set`, selvom ACL'en var
>    skrevet — `ip access-group BLOK-ISP out` var aldrig kørt på interfacet.

**GEM.**

---

## Step 9 — Test NAT

```cisco
! fra PC i VLAN 10 eller 30 - skal VIRKE
ping 200.2.2.2

! fra PC i VLAN 20 eller 40 - skal TIME OUT
ping 200.2.2.2
```

```cisco
show ip nat translations      ! rækker for VLAN 10/30's private IP -> 200.2.2.1:port
show ip nat statistics
show access-lists NAT-TILLADT ! match-tæller på permit-linjerne stiger (10/30)
show access-lists BLOK-ISP    ! match-tæller på deny-linjerne stiger (20/40)
```

---

## ⚠️ Fejl vi ramte i denne opgave

> [!warning]
> - Manglende `vlan 99` fik `name vlan-99-native` til at ramme VLAN 40 i stedet.
> - SVI'er for 10/20/30/40 + `encapsulation dot1Q` under en SVI hører ikke hjemme på en
>   2960 — RoaS sker på routeren, native VLAN sættes på trunk-porten.
> - Router-2 fik ved en fejl `.30`/`.40`-subinterfaces → gjorde de statiske ruter til de net
>   virkningsløse (`C` slår altid `S`).
> - `192.168.99.2` sat på **begge** routere — matchede ikke switchenes `ip
>   default-gateway`. Hver switch skal pege på **sin egen** routers `.99`-IP.
> - DHCP virkede ikke for **noget**, fordi DHCP-serverens egen NIC manglede static IP —
>   ikke et pool- eller helper-problem.
> - Overflødig `ip route 200.2.2.0 … via 10.10.10.1` blev liggende efter OSPF var oppe.
> - `Gig0/0` (linket mellem routerne) manglede `ip nat inside` — VLAN 30's trafik blev
>   aldrig oversat.
> - **NAT-udvælgelse ≠ blokering.** At undlade VLAN 20/40 fra NAT-ACL'en stoppede dem ikke,
>   fordi routerne stadig kunne rute trafikken internt begge veje. Krævede en ægte
>   filter-ACL (`deny` + `permit ip any any`) sat `out` på ISP-interfacet.
> - Filter-ACL'en var to gange virkningsløs undervejs: én gang fordi den var **tom**
>   (slettet og ikke genskabt), én gang fordi den slet ikke var **bundet** til interfacet.
>   `show access-lists <navn>` (indhold) og `show ip interface <intf> | include access
>   list` (binding) er to **forskellige** ting — tjek altid begge.

---

## 🧭 Diagnostik-rækkefølge der virkede

1. **Ping egen gateway** fra hosten → isolerer om fejlen er L2 (switch/VLAN/trunk) eller
   længere ude.
2. **Ping det andet routers WAN-IP** (`10.10.10.x`) → isolerer om R1↔R2-linket virker.
3. **`show ip route` på begge routere** → mangler en `C`/`S`/`O`-linje til destinationen?
4. **`show vlan brief` + `show interfaces trunk`** på switchene → rigtige VLAN, rigtige
   allowed-lister?
5. For ACL/NAT-problemer, tjek **binding og indhold hver for sig**:
   - `show ip interface <intf> | include access list` — er den overhovedet **sat på**
     interfacet, og i hvilken retning?
   - `show access-lists <navn>` — har den **linjer**, og matcher tællerne når du tester?
6. **Traceroute for at finde blokeringspunktet** — den sidste hop der svarer, er typisk
   lige før problemet (fx en router hvor en outbound-ACL dropper pakken).
7. Test altid **fra selve PC'en** (Desktop → Command Prompt / ping), ikke fra en routers
   CLI — kilde-IP'en er anderledes og rammer ikke de samme ACL-linjer.
