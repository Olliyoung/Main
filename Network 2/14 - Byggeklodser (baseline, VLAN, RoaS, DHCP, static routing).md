---
tags: [network-2, cisco, cheat-sheet, exam-prep, vlan, dhcp, etherchannel, routing]
aliases: ["Byggeklodser", "Egne scripts forklaret", "Kommando-bibliotek"]
---

# 14 — Byggeklodser (klar til at genbruge)

> [!info] Hvad denne note er
> Dine egne scripts fra `Network 2/Scripts/` samlet, renset op og forklaret linje for
> linje. Det er **byggeklodser**, ikke en færdig løsning til en bestemt opgave — du
> tager det stykke du mangler (VLAN, trunk, RoaS, DHCP, routing...), retter adresser og
> navne til den opgave du står i, og sætter det sammen selv.
> Vil du vide **hvorfor** en kommando virker som den gør, er det [[13 - Netvaerksforstaaelse (hvorfor virker det saadan)]]
> du skal kigge i — denne note er "hvad skal der stå", den er "hvorfor står det der".

---

## 1. Device baseline — hver enhed, hver gang

Samme otte-ti linjer går igen på alt: routere, switche, servere. Kør dem først, før
noget andet.

```
configure terminal

hostname R1                          ! sæt navnet FØRST - crypto keys bruger det
enable secret 1337                   ! krypteret enable-password (secret > password)
service password-encryption          ! krypterer line-passwords (console/vty) i configen

no ip domain-lookup                  ! stopper routeren i at forsøge DNS-opslag på tastefejl
ip domain-name OYL.com               ! kræves FØR crypto key generate rsa

username admin secret 1337           ! lokal bruger til SSH-login

crypto key generate rsa              ! genererer RSA-nøglepar - beder om nøglestørrelse (svar 1024)
ip ssh version 2                     ! slår SSHv1 fra, kun det sikre SSHv2 tilbage

line console 0
 password 1337
 login local                         ! login mod den lokale brugerdatabase, ikke line password
exit

line vty 0 15
 transport input ssh                 ! kun SSH ind - telnet lukket
 login local
exit

banner motd #
*************************************
* Unauthorized access is prohibited *
* This is a private network device  *
*************************************
#
```

> [!warning] Rækkefølgen er ikke tilfældig
> `hostname` og `ip domain-name` **skal** stå før `crypto key generate rsa` — IOS bruger
> `hostname.domain-name` som en del af nøgle-labelen. Kører du `crypto key generate rsa`
> først, laver den nøglen med det forkerte (eller manglende) navn, og du må slette og
> generere igen. Samme logik: `service password-encryption` virker kun på passwords der
> **allerede findes** når kommandoen køres — sæt den derfor tidligt, men det er ikke
> katastrofalt at gense den, den krypterer bare igen.

> [!bug] Fundet i vores egne scripts — S1 mangler nøglerne
> `S1 Conf`-scriptet har `ip ssh version 2`, men **ingen** `crypto key generate rsa`
> nogen steder i filen (`S2 Conf` og `R1 Conf` har den). Uden nøgler kommer SSH aldrig
> op på S1, selvom resten af opsætningen ser rigtig ud. Værd at tjekke igen næste gang
> du bruger det script som skabelon.

### Til en server/PC-enhed (samme idé, andre standardværdier)

```
hostname Server-PT
enable secret class
service password-encryption

no ip domain-lookup
ip domain-name srwe.local

username admin privilege 15 secret admin123!   ! privilege 15 = fuld adgang med det samme

line console 0
 password cisco
 login local
exit

line vty 0 15
 transport input ssh
 login local
exit

crypto key generate rsa
ip ssh version 2
```

---

## 2. VLAN, access-porte og "sorte huller"

Mønster: opret VLAN'erne → sæt dem på de rigtige access-porte → parker alle **ubrugte**
porte i et dedikeret "blackhole"-VLAN, shutdown, så ingen kan plugge sig ind og få adgang
ved et uheld.

```
vlan 10
 name vlan-10
vlan 20
 name vlan-20
vlan 30
 name vlan-30
vlan 99
 name vlan-99-native            ! native VLAN - skal aldrig bære almindelig klienttrafik
vlan 666
 name vlan-666-blackhole        ! "skraldespand" til ubrugte porte
exit

interface vlan 10
 description vlan-10
 no shutdown                    ! SVI'en skal aktiveres selvom den ikke skal have IP her
exit

interface vlan 99
 ip address 192.168.99.99 255.255.255.0
 description vlan-99-native
 no shutdown
exit

ip default-gateway 192.168.99.1  ! switchens egen management-gateway - kun relevant hvis switchen selv skal nås udefra
```

> [!info] Hvorfor et blackhole-VLAN
> En port du glemmer at lukke ned, står som udgangspunkt i VLAN 1 og kan nås af alt der
> plugges i den. Ved i stedet at sætte **alle** ubrugte porte i et VLAN der ikke findes
> nogen steder i din trunk-tillladte liste, og lægge `shutdown` på dem, er porten dobbelt
> beskyttet: den er nede, og selv hvis nogen tænder den, lander de i et VLAN uden nogen
> vej videre.

```
interface range FastEthernet0/3-9
 description Unused ports
 switchport mode access
 switchport access vlan 666
 shutdown
exit
```

### Access-port med port-security + PortFast

```
interface FastEthernet0/1
 description SALES
 switchport mode access
 switchport access vlan 10
 switchport port-security
 switchport port-security maximum 2            ! kun 2 MAC-adresser tilladt på porten
 switchport port-security violation restrict    ! restrict = drop + log, PC'en dør ikke
 switchport port-security mac-address sticky    ! lærer og "fastlåser" de(n) rigtige MAC(s)
 spanning-tree portfast                         ! PC får link med det samme, ikke efter 30 sek
 spanning-tree bpduguard enable                 ! lukker porten hvis der modtages en BPDU
 no shutdown
exit
```

> [!info] `restrict` vs `shutdown` som violation-mode
> `restrict` dropper trafik fra en uautoriseret MAC og logger det, men porten forbliver
> oppe — praktisk hvis du vil se hvad der sker uden at rive forbindelsen ned. `shutdown`
> (default) sætter porten i err-disabled ved første overtrædelse — strengere, men kræver
> manuel genopretning (`shutdown` / `no shutdown`) eller `errdisable recovery`. Begge
> scripts i dette bibliotek bruger faktisk begge varianter forskellige steder — vælg
> bevidst efter hvor strengt du vil være, ikke tilfældigt.

---

## 3. Trunk, EtherChannel og STP-prioritet

```
! Manuel trunk (uden EtherChannel) - ét fysisk link
interface GigabitEthernet0/1
 switchport mode trunk
 switchport nonegotiate                 ! send ikke DTP - modparten er ikke Cisco/ikke sat op til at forhandle
 switchport trunk allowed vlan 10,20,30,99
exit

! EtherChannel med LACP - to eller flere fysiske porte bundtet
interface range FastEthernet0/23-24
 duplex full
 speed 100
 channel-group 1 mode active            ! active = LACP, forhandler aktivt
exit

interface Port-channel 1
 switchport mode trunk
 switchport trunk native vlan 999
 switchport trunk allowed vlan 10,20,30,99,999
 switchport nonegotiate
 no shutdown
exit
```

> [!warning] Konfigurér på Port-channel-interfacet, ikke kun de fysiske porte
> Når portene først er i `channel-group`, skal trunk-indstillingerne (mode, native vlan,
> allowed vlan) sættes på det **logiske** `Port-channel`-interface. Sætter du dem kun på
> de fysiske porte bagefter, risikerer du mismatch mellem porten og bundtet, og porten
> ryger ud som `(I)` i `show etherchannel summary`. Se [[13 - Netvaerksforstaaelse (hvorfor virker det saadan)]]
> for hvad de forskellige koder betyder.

### STP-prioritet — fordel roden mellem to switche

```
! S1 - skal være root for VLAN 10 og 30
spanning-tree mode rapid-pvst
spanning-tree vlan 10 priority 24576
spanning-tree vlan 30 priority 24576
spanning-tree vlan 20 priority 28672     ! højere tal = mindre foretrukket, S2 vinder her
spanning-tree vlan 99 priority 28672

! S2 - skal være root for VLAN 20 og 99 (det modsatte mønster)
spanning-tree mode rapid-pvst
spanning-tree vlan 20 priority 24576
spanning-tree vlan 99 priority 24576
spanning-tree vlan 10 priority 28672
spanning-tree vlan 30 priority 28672
```

> [!tip] Det er ikke en fejl at de er spejlvendte
> Dette er et bevidst mønster, ikke en tilfældighed: ved at lade S1 og S2 skiftes til at
> være root for forskellige VLAN'er, bruges **begge** uplinks aktivt i stedet for at ét
> link altid står blokeret og gør ingenting. Det er den samme idé som HSRP-load-sharing
> — bare på Layer 2 i stedet for Layer 3. Prioriteten skal være et multiplum af 4096
> (`24576`, `28672`, standard er `32768`), ellers afviser IOS værdien.

---

## 4. Router-on-a-stick

```
interface GigabitEthernet0/1.10
 description SALES
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.0
exit

interface GigabitEthernet0/1.20
 description ENGINEERING
 encapsulation dot1Q 20
 ip address 192.168.20.1 255.255.255.0
exit

interface GigabitEthernet0/1.99
 description MANAGEMENT
 encapsulation dot1Q 99
 ip address 192.168.99.1 255.255.255.0
exit

interface GigabitEthernet0/1.999
 description NATIVE-PARKING
 encapsulation dot1Q 999 native     ! ingen IP - native VLAN skal ikke bruges til noget
exit
```

Husk det fysiske forældre-interface (`GigabitEthernet0/1` uden underinterface) skal have
sin egen `no ip address` + `no shutdown` — se [[01 - Layer 2 foundation]] hvis det driller.

---

## 5. Statisk routing med Loopbacks (P2P-øvelse / "conf t"-mønster)

Dette er mønsteret fra en simpel tre-router serie-øvelse: hver router har en `Loopback0`
som sin egen "identitet" (tænk på den som en server bag routeren), og statiske ruter
peger på naboens loopback via det fysiske link imellem dem.

```
! === R1 ===
interface GigabitEthernet0/0
 ip address 10.0.12.1 255.255.255.252
 no shutdown
exit

interface GigabitEthernet0/2
 ip address 10.0.13.1 255.255.255.252
 no shutdown
exit

interface Loopback0
 ip address 1.1.1.1 255.255.255.255      ! /32 - repræsenterer "R1's eget net"
exit

ip route 2.2.2.2 255.255.255.255 10.0.12.2   ! vejen til R2's loopback
ip route 3.3.3.3 255.255.255.255 10.0.13.2   ! vejen til R3's loopback
ip route 203.0.113.0 255.255.255.0 10.0.13.2 ! vejen videre til R3's yderste net
```

```
! === R2 ===
interface GigabitEthernet0/0
 ip address 10.0.12.2 255.255.255.252
 no shutdown
exit

interface Loopback0
 ip address 2.2.2.2 255.255.255.255
exit

ip route 0.0.0.0 0.0.0.0 10.0.12.1           ! default - alt andet går mod R1
```

```
! === R3 ===
interface GigabitEthernet0/2
 ip address 10.0.13.2 255.255.255.252
 no shutdown
exit

interface GigabitEthernet0/1
 ip address 203.0.113.1 255.255.255.0
 no shutdown
exit

interface Loopback0
 ip address 3.3.3.3 255.255.255.255
exit

ip route 192.168.0.0 255.255.0.0 10.0.13.1   ! vejen tilbage mod R1's interne net
ip route 2.2.2.2 255.255.255.255 10.0.13.1   ! vejen til R2's loopback (via R1)
```

> [!info] Hvorfor `/32` på en loopback
> En loopback-adresse repræsenterer routeren selv, ikke et segment med flere enheder —
> den har derfor ikke brug for et helt subnet, kun præcis én adresse. `/32` betyder
> "denne ene IP, intet andet". Loopbacks bruges tit i øvelser som en nem stand-in for
> "en server bag routeren" uden at skulle sætte en rigtig server op.

---

## 6. DHCP — pools, excluded, relay

```
! på DHCP-serveren (kan være routeren selv eller en dedikeret server)
ip dhcp excluded-address 192.168.10.1 192.168.10.20   ! statiske adresser puljen ikke må uddele
ip dhcp excluded-address 192.168.20.1 192.168.20.20
ip dhcp excluded-address 192.168.30.1 192.168.30.20

ip dhcp pool SALES
 network 192.168.10.0 255.255.255.0
 default-router 192.168.10.1        ! gateway klienterne får udleveret
 dns-server 8.8.8.8
 domain-name srwe.local
exit

ip dhcp pool ENGINEERING
 network 192.168.20.0 255.255.255.0
 default-router 192.168.20.1
 dns-server 8.8.8.8
 domain-name srwe.local
exit
```

```
! på routeren mellem klient-VLAN og DHCP-serveren
interface GigabitEthernet0/1.10
 ip helper-address 10.0.12.2        ! relay til DHCP-serverens IP, ét pr. VLAN der IKKE har serveren lokalt
exit

interface GigabitEthernet0/1.20
 ip helper-address 10.0.12.2
exit
```

> [!warning] Excluded-address skal matche default-router
> Puljen kender ikke automatisk sin egen gateway-adresse som "optaget" — glemmer du
> `ip dhcp excluded-address` for `.1`, kan DHCP finde på at udlevere gateway-IP'en til en
> klient, og så kolliderer de. Ekskludér altid fra `.1` og op til der hvor dine statiske
> adresser (switch-management, servere) slutter.

---

## 7. Interface-beskrivelser — den kedelige vane der redder tid

```
interface GigabitEthernet0/0
 description R2 Connected to R1
 ip address 10.0.12.2 255.255.255.252
 no shutdown
exit
 do write memory
```

> [!tip] Hvorfor det er værd at gøre konsekvent
> En `description`-linje koster fem sekunder at skrive og sparer dig for at gætte om
> seks uger, eller midt i en fejlfindingssession, hvilket kabel der faktisk sidder i
> hvilken port. Skriv **hvad** porten forbinder til og **hvorfor** — "R1 connected to
> R2" er bedre end "link" eller ingenting. `do write memory` direkte fra interface-mode
> er en genvej der gemmer uden at forlade config-mode.

---

## 8. Verificér efter du har limet blokke sammen

```
show vlan brief                        ! findes VLAN'et, sidder rigtige porte i det
show interfaces trunk                  ! tillader trunken VLAN'et
show etherchannel summary              ! er bundtet SU, ikke (I) eller (D)
show ip interface brief                ! er alt up/up, har rigtig IP
show ip route                          ! kender routeren vejen - eller default-ruten
show ip dhcp binding                   ! har nogen faktisk fået en lejet adresse
show running-config interface <if>     ! stemmer det der faktisk står overens med planen
```

---

## Hvad ellers kan bruges til at komme igennem det her

- **[[13 - Netvaerksforstaaelse (hvorfor virker det saadan)]]** — hvorfor-laget over
  denne note: ACL vs firewall, STP-valg, EtherChannel-load-balancering, HSRP-timere,
  DHCP-relay-detaljer, OSPF cost/timere, NAT-terminologi, plus en ordliste.
- **[[12 - Network Troubleshooting]]** — den systematiske rækkefølge når noget ikke
  virker: nedefra og op, symptom/årsag-tabeller pr. OSI-lag.
- **[[02 - HSRP]]**, **[[03 - OSPF]]**, **[[04 - NAT and PAT]]**, **[[05 - ACL]]** —
  de fulde kommando-referencer for hvert af de protokoller der ikke er dækket i denne
  note (denne note er L1/L2 + DHCP + basal routing, ikke redundans/dynamisk
  routing/NAT/ACL).
- Din `Network 2/PDF & PPTX/Præsentationer-20260914/`-mappe har originalslides for
  **Modul 7 (WAN)** og **Modul 9 (QoS)** — ingen af dem er lavet til noter i vaulten
  endnu. Sig til hvis du vil have dem bygget samme stil som denne, næste gang du har
  gennemgået dem.
- `Victor Repitition`-mappen har en version mærket **"NTP virker slet ikke uanset
  hvad"** — NTP-fejlfindingen (uret slæbes, ikke trædes; ur skal sættes tæt manuelt
  først; Fast Forward Time ødelægger konvergens) står i [[13 - Netvaerksforstaaelse (hvorfor virker det saadan)]]
  under NTP-afsnittet, hvis det er dér den sidder fast.

---

## Relaterede noter

[[00 - Overview & topology]] · [[01 - Layer 2 foundation]] · [[02 - HSRP]] ·
[[03 - OSPF]] · [[04 - NAT and PAT]] · [[05 - ACL]] ·
[[13 - Netvaerksforstaaelse (hvorfor virker det saadan)]]
