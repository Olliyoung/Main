---
tags: [network-2, cisco, understanding, exam-prep, acl, etherchannel, stp, hsrp, ospf, nat, dhcp, ntp]
aliases: ["Netværksforståelse", "Hvorfor virker protokollerne sådan"]
---

# 13 — Netværksforståelse (hvorfor virker det sådan)

> [!info] Hvad denne note er
> [[01 - Layer 2 foundation]] til [[05 - ACL]], [[09 - CDP, LLDP & NTP]] og
> [[10 - Byg netvaerket (VLAN, RoaS, static, DHCP, OSPF, NAT)]] viser **kommandoerne** —
> hvad du skal skrive. Denne note er **hvorfor**-laget under dem: hvorfor protokollen
> overhovedet findes, hvad der går galt hvis den ikke er der, og hvordan du læser
> symptomerne når noget fejler. Læs den når du vil *forstå*, ikke når du skal *taste*.
> Ekstra baggrund ud over det oprindelige dokument er markeret med `[!info]`-bokse.

---

## ACL vs firewall — hvorfor begge?

Kort svar: de sidder forskellige steder og løser forskellige problemer.

En **firewall** står typisk i kanten af netværket og kigger på trafik mellem "inde" og
"ude". Den er **stateful**: den husker at du sendte en forespørgsel ud, og lukker
automatisk svaret ind igen. Den kan se ind i selve trafikken — genkende at noget på port
443 ikke opfører sig som HTTPS, blokere kendt malware, logge hvem der gjorde hvad.

En **ACL** sidder på en router eller switch inde i netværket. Den er **stateless**: den
kigger på én pakke ad gangen og kender ikke sammenhængen. Den kan kun se adresser,
protokol og portnumre — ikke indholdet.

> [!info] Hvad "stateful" konkret betyder
> En stateful firewall følger TCP's håndtryk (SYN → SYN/ACK → ACK) og ved derfor om en
> pakke er starten på en ny forbindelse eller et svar på en du selv startede. En ACL kan
> ikke det — den ser en enkelt pakke og dømmer ud fra `permit`/`deny`-linjerne, uanset
> om pakken er "ny" eller et svar. Det er derfor en ACL skal have en linje for *begge*
> retninger, hvis begge skal virke, mens en firewall automatisk åbner returtrafikken.
> Firewall'en arbejder typisk helt op i OSI-lag 7 (indhold); en almindelig ACL stopper
> ved lag 3–4 (adresse + port).

### Hvorfor du vil have ACL selvom du har firewall

**Firewallen ser ikke intern trafik.** Trafik mellem VLAN 10 og VLAN 20 går gennem din
router, aldrig forbi kantfirewallen. Vil du forhindre at HR-afdelingen kan nå
produktionsserverne, skal det ske på routeren. Firewallen kan ikke stoppe noget den
aldrig ser.

**Dybde i forsvaret.** Kompromitteres firewallen, eller kommer en angriber ind ad en
anden vej (en gæst i mødelokalet, en inficeret bærbar), er ACL'erne stadig der.
Sikkerhed skal ikke afhænge af én enkelt enhed.

**ACL er billig og hurtig.** Den kører i routerens hardware og koster næsten ingenting.
At sende al intern trafik gennem en firewall for at filtrere den ville være langsomt og
dyrt.

**ACL bruges til meget mere end sikkerhed.** Samme mekanisme vælger hvilke net der
NAT'es, hvilke ruter der redistribueres, hvilken trafik der prioriteres i QoS. I dit eget
netværk er `NAT-INSIDE` ikke en sikkerhedsregel — det er en liste over hvem der må
oversættes.

> [!tip] Tænk på det som lag
> Firewallen er hoveddøren. ACL'erne er låsene på de indvendige døre. Du vil have begge,
> og de gør ikke det samme arbejde.

---

## ACL i dybden

### Standard vs extended

| | Standard | Extended |
|---|---|---|
| Ser på | Kun **kilde**-IP | Kilde, destination, protokol, portnumre |
| Nummerinterval | 1–99, 1300–1999 | 100–199, 2000–2699 |
| Bruges til | NAT-udvælgelse, simpel filtrering | Rigtig filtrering |
| Placering | Tæt på **destinationen** | Tæt på **kilden** |

> [!info] Numrene betyder mindre end du tror
> 1–99 og 100–199 er de "klassiske" intervaller; 1300–1999 og 2000–2699 er senere
> tilføjede "expanded ranges" — funktionelt identiske, bare flere numre at vælge
> imellem. I praksis bruger du næsten altid **navngivne** ACL'er
> (`ip access-list extended NAVN`) i stedet for numre — de er lettere at læse i
> `show running-config`, og du undgår at løbe tør for numre.

Placeringsreglen giver sig selv: en standard-ACL kan kun se hvem pakken kommer fra, så
sætter du den for tidligt, blokerer du også trafik der skulle et andet sted hen. En
extended ACL kender destinationen og kan derfor droppe pakken med det samme, før den
spilder båndbredde.

```
! Standard - kun kilde
ip access-list standard NAT-INSIDE
 permit 192.168.20.0 0.0.0.255
exit

! Extended - kilde, destination, protokol, port
ip access-list extended BLOKER-WEB
 deny tcp any host 172.17.1.3 eq 80
 permit ip any host 172.17.1.3
exit
```

### Retning — inbound vs outbound

Retningen er set **fra routerens synspunkt**, ikke fra din.

- **`in`** — pakken er på vej **ind i** routeren gennem dette interface. Filtreres før
  routing-beslutningen.
- **`out`** — pakken har passeret routing og er på vej **ud af** dette interface.

> [!tip] Huskeregel
> Stå "inde i" routeren og se ud gennem interfacet: kommer trafikken imod dig, er det
> `in`; går den væk fra dig, er det `out`. Samme logik gælder `access-class` på VTY-linjer
> (fjernadgang) — se [[05 - ACL]] for den forskel.

```
interface GigabitEthernet0/1
 ip access-group MIN-ACL in
```

Hvilken skal du vælge? **`in` er normalt bedst.** Pakken droppes før routeren spilder
arbejde på at slå destinationen op, og den ene ACL rammer alt der kommer fra den retning.

`out` er nyttig når du vil beskytte én ting uanset hvor trafikken kommer fra. Det var
tilfældet med serveren: ACL'en sad `out` på interfacet ned mod serveren, så al trafik mod
den blev filtreret, uanset hvilket VLAN afsenderen sad i. Havde vi brugt `in`, skulle den
samme regel ligge på hvert enkelt indgående interface.

> [!warning] Ét interface, én ACL, én retning
> Du kan have én ACL `in` og én `out` pr. interface — ikke to i samme retning. Sætter du
> en ny, erstatter den den gamle uden varsel.

### Implicit deny — den usynlige linje

Hver ACL slutter med et skjult `deny any`. Den vises ikke i `show access-lists`, men den
er der altid.

Konsekvensen: **det du ikke eksplicit tillader, er forbudt.** Det er derfor
`ip nat inside source list NAT-INSIDE ...` med kun `permit 192.168.20.0` automatisk
spærrer VLAN 10 — VLAN 10 matcher ingen linje og falder i den implicitte deny.

Det er også derfor "tillad alt undtagen X" kræver en afsluttende permit:

```
ip access-list extended KUN-IKKE-WEB
 deny tcp any host 172.17.1.3 eq 80
 permit ip any host 172.17.1.3     ← NØDVENDIG
exit
```

Uden den sidste linje ville alt andet end port 80 også blive blokeret — det stik
modsatte af hensigten.

> [!info] Gør den usynlige linje synlig
> Den implicitte deny tæller ikke i `show access-lists`, så du kan ikke se om trafik
> rammer den. Skriv den selv med `log`, så får du både en tæller og en syslog-besked:
> ```
> ip access-list extended MIN-ACL
>  ...
>  deny ip any any log
> exit
> ```
> Uvurderligt når du fejlfinder "hvorfor blokerer den her ACL trafik jeg troede var
> tilladt".

### Rækkefølge afgør alt

ACL'en læses **top-til-bund, første match vinder**. Så snart en linje matcher, stopper
behandlingen — resten læses aldrig.

```
! VIRKER
deny tcp any host 10.0.0.1 eq 80
permit ip any host 10.0.0.1

! VIRKER IKKE - permit fanger alt først
permit ip any host 10.0.0.1
deny tcp any host 10.0.0.1 eq 80      ← nås aldrig
```

Tommelfingerregel: **specifikke regler før generelle.**

### Sekvensnumre

Named ACL'er nummererer linjerne automatisk i spring af 10 — første linje bliver 10,
næste 20, osv. Springene findes netop for at du kan skyde noget ind imellem senere.

```
show access-lists NAVN
```

Viser de faktiske numre. **Gæt aldrig** — de kan være anderledes end du tror, hvis du har
redigeret undervejs.

Numrene lader dig redigere uden at genskabe hele ACL'en:

```
configure terminal
ip access-list extended MIN-ACL
 no 20                                  ← slet linje 20
 15 permit tcp any any eq 443           ← indsæt mellem 10 og 20
exit
```

> [!warning] ACL'er er additive
> Kører du et script igen, **overskrives intet** — nye linjer lægges ovenpå. Det var
> præcis fejlen med `NAT-INSIDE`: den gamle `permit 192.168.10.0` blev aldrig fjernet, så
> VLAN 10 kunne fortsat NAT'es selvom vi havde tilføjet en ny stram linje. Ryd op
> eksplicit:
> ```
> no ip access-list standard NAVN
> ```
> eller slet linje for linje med `no permit ...` inde i ACL'en.

### Wildcard-masker

Omvendt af en subnetmaske. **0 = skal matche, 1 = ligegyldig.**

| Præfiks | Subnetmaske | Wildcard | Dækker |
|---|---|---|---|
| /24 | 255.255.255.0 | 0.0.0.255 | 256 adresser |
| /27 | 255.255.255.224 | 0.0.0.31 | 32 adresser |
| /29 | 255.255.255.248 | 0.0.0.7 | 8 adresser |
| /30 | 255.255.255.252 | 0.0.0.3 | 4 adresser |

Genvej: **255 minus subnetmasken** i hver oktet. 255 − 224 = 31.

> [!info] Hvorfor "255 minus" virker
> En wildcard er den bitvise negation af masken. Masken `224` er binært `1110 0000`;
> vend hver bit om og du får `0001 1111` = `31`. "255 minus masken" er bare en hurtig
> genvej til samme regning, fordi 255 er otte 1-taller (`1111 1111`), og at trække en
> byte fra `1111 1111` giver automatisk den inverterede bitmønster.

Genveje i syntaksen:
- `host 10.0.0.1` = `10.0.0.1 0.0.0.0`
- `any` = `0.0.0.0 255.255.255.255`

Flere sammenhængende net kan dækkes i én linje, hvis de ligger på en binær grænse:
`172.18.0.0 0.0.3.255` dækker 172.18.0.x til 172.18.3.x. Smart, men separate linjer pr.
net er lettere at læse og lettere at forklare til en eksamen.

### Kontrol

```
show access-lists NAVN                          ! regler + match-tællere
show ip interface Gi0/1 | include access list   ! hvor sidder den, hvilken retning
clear access-list counters                      ! nulstil tællere før en test
```

Match-tællerne er dit bedste fejlfindingsværktøj. Stiger tælleren ikke når du sender
trafik, rammer trafikken slet ikke ACL'en — så er problemet placeringen eller retningen,
ikke reglerne.

---

## EtherChannel — PAgP og LACP

### Problemet det løser

Har du to kabler mellem to switche, blokerer STP det ene for at undgå loop. Du får
redundans, men ikke dobbelt båndbredde.

EtherChannel bundter flere fysiske porte til **ét logisk interface** (Po1, Po2...). STP
ser kun bundtet, ikke de enkelte kabler, så alle links er aktive samtidig. Falder én port
ud, fortsætter de øvrige — uden STP-omkonvergering.

> [!info] "Dobbelt bandbredde" er ikke helt bogstaveligt
> EtherChannel fordeler trafik pr. **flow** (typisk på en hash af kilde/destination-IP
> eller -MAC), ikke pr. pakke. Én samtale mellem to bestemte enheder følger derfor altid
> det samme fysiske kabel i bundtet — den samtale bliver aldrig hurtigere end ét link.
> Gevinsten er at *mange* samtidige samtaler samlet set fordeles over flere kabler.

### De to protokoller

| | PAgP | LACP |
|---|---|---|
| Standard | Cisco-proprietær | IEEE 802.3ad — åben |
| Aktiv tilstand | `desirable` | `active` |
| Passiv tilstand | `auto` | `passive` |
| Vælg når | Rent Cisco-miljø | Blandet udstyr — normalt førstevalg |

Mindst én side skal være aktiv. `auto`+`auto` eller `passive`+`passive` danner intet
bundt, fordi ingen tager initiativet.

```
! LACP
interface range FastEthernet0/21-22
 shutdown
 switchport mode trunk
 switchport trunk native vlan 99
 switchport trunk allowed vlan 10,20,77,99
 duplex full
 speed 100
 channel-group 2 mode active
 no shutdown
exit

! PAgP - kun mode-linjen er anderledes
 channel-group 1 mode desirable
```

### Hvorfor `shutdown` først

Porten lukkes før konfigurationen og åbnes bagefter. Ellers står den kortvarigt som
selvstændig trunk, mens bundtet endnu ikke er dannet — og to selvstændige trunks mellem
samme par switche er et loop.

### Alt skal være identisk

En port ryger ud af bundtet hvis speed, duplex, trunk-mode, native VLAN eller allowed
VLAN afviger — på nogen af portene, på nogen af siderne.

```
show etherchannel summary
```

| Kode | Betyder |
|---|---|
| `SU` | Po er oppe og i brug — det du vil se |
| `(P)` | Porten er med i bundtet |
| `(I)` | Individuel — ikke med i bundtet |
| `(D)` | Nede |

Ser du `(I)` eller `(D)`, så sammenlign konfigurationen på begge ender linje for linje.

Channel-group-numre behøver ikke matche mellem de to switche, men det er god praksis at
lade dem gøre det — det gør fejlfinding langt lettere.

---

## STP — hvorfor porte er blokeret

### Loop-problemet

Switche har **ingen TTL**. En router tæller hop ned og dropper pakken når tælleren når
nul. En switch videresender broadcasts ud af alle porte og har intet der stopper en
pakke der kommer tilbage.

I et mesh betyder det: broadcast sendes ud, når nabo-switchen, sendes videre, kommer
tilbage til den første, sendes ud igen. Den dør aldrig af sig selv. Efter et sekund har
du millioner af kopier, og netværket er nede.

### Løsningen

STP bygger et loop-frit træ og **blokerer** de links der ville lukke en ring. Fire switche
i fuldt mesh har seks forbindelser, men kun tre kan være aktive.

En blokeret port er **ikke en fejl**. Den er reserve. Falder en aktiv sti ud, skifter den
til forwarding på få sekunder.

> [!info] Hvordan STP vælger hvad der bliver blokeret
> Alle switche vælger først én fælles **root bridge**: den med lavest Bridge-ID (default
> priority `32768` + switchens MAC-adresse — lavest vinder, så laveste MAC afgør ved
> uafgjort). Hver af de øvrige switche udpeger så sin **root port** (billigste vej til
> roden) og hvert segment får én **designated port**. Alt andet bliver `BLK`/`ALTN`.
> Det er derfor du kan *styre* hvem der er root — sæt en lavere priority manuelt i
> stedet for at overlade det til tilfældige MAC-adresser.

```
show spanning-tree vlan 10
```

| Rolle | Betyder |
|---|---|
| `Root FWD` | Vejen mod root bridge — aktiv |
| `Desg FWD` | Designated — aktiv |
| `Altn BLK` | Alternativ sti — blokeret, i beredskab |

### Rapid PVST+

```
spanning-tree mode rapid-pvst
```

Rapid = sekunder i stedet for op mod et minut ved omkonvergering. PVST+ = ét træ pr.
VLAN, så VLAN 10 og VLAN 20 kan blokere forskellige porte og fordele trafikken.

> [!info] Hvorfor klassisk STP er så langsom
> Original 802.1D bruger faste timere — `forward delay` 15 sekunder (gennemløbes to
> gange: listening → learning, ca. 30 sekunder i alt) og `max age` 20 sekunder før en
> død nabo opdages. Rapid PVST+ (802.1w) erstatter det med direkte
> handshake-beskeder mellem switche, så en ændring kan slå igennem på under et sekund i
> stedet for at vente timerne ud.

**Alle switche skal køre samme tilstand.** Én switch på PVST+ mens resten kører Rapid
giver langsom og uforudsigelig konvergering.

### Styr hvem der er root

Uden konfiguration vælges root ud fra laveste MAC-adresse — altså tilfældigt.

```
spanning-tree vlan 10,20,77,99 root primary      ! på den ønskede root
spanning-tree vlan 10,20,77,99 root secondary    ! på backup
```

### PortFast og BPDU Guard

**PortFast** springer listening/learning over på access-porte, så en PC får link med det
samme i stedet for efter 30 sekunder.

**BPDU Guard** lukker porten (err-disabled) hvis den modtager en BPDU. En PC sender
aldrig BPDU'er, så en BPDU betyder at der er tilsluttet en switch — enten ved en fejl
eller som angreb.

De to hører sammen: PortFast antager at der ikke sidder en switch, BPDU Guard håndhæver
antagelsen.

```
interface FastEthernet0/3
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 spanning-tree bpduguard enable
exit
```

> [!warning] Aldrig på en trunk
> BPDU'er er helt normale på trunks og EtherChannel-porte. Sætter du BPDU Guard der,
> ryger porten i err-disabled øjeblikkeligt, og du river dit eget netværk ned.

Genopret en err-disabled port:
```
interface FastEthernet0/3
 shutdown
 no shutdown
```

Eller automatisk:
```
errdisable recovery cause bpduguard
errdisable recovery interval 300
```

---

## Inter-VLAN routing — router-on-a-stick

### Problemet

Et VLAN er et selvstændigt broadcast-domæne og et selvstændigt subnet. En Layer
2-switch kan ikke flytte trafik mellem VLAN'er — det kræver routing.

Den naive løsning er ét fysisk router-interface pr. VLAN. Med fire VLAN'er kræver det
fire porte og fire kabler.

### Løsningen

Ét fysisk interface, en trunk, og et **subinterface** pr. VLAN. Routeren læser
VLAN-tagget og behandler pakken som om den kom fra det rigtige interface.

```
interface GigabitEthernet0/1
 no ip address
 no shutdown
exit

interface GigabitEthernet0/1.10
 encapsulation dot1Q 10
 ip address 192.168.10.3 255.255.255.0
exit

interface GigabitEthernet0/1.20
 encapsulation dot1Q 20
 ip address 192.168.20.3 255.255.255.0
exit
```

> [!info] Grænsen for router-on-a-stick
> `802.1Q`-tagget lægger 4 byte oveni hver frame — normalt uden betydning, men det er
> stadig **ét fysisk kabel** der bærer trafik for *alle* VLAN'er samtidig. Med mange
> VLAN'er eller meget trafik bliver det kablet en flaskehals. Løsningen i større
> netværk er en Layer 3-switch med en SVI (`interface vlan 10`) pr. VLAN i stedet —
> routing sker internt i switchen uden at nogen trafik skal ud og ind ad samme kabel.
> Se [[11 - Network Design]] for hvornår den overgang giver mening.

### Tre ting der koster tid

**Subinterfaces skal ligge på det interface hvor kablet faktisk sidder.** Det kostede os
lang tid: R2's subinterfaces sad på G0/1, men trunken gik til G0/2. VLAN-frames blev
tagget og sendt ud ad et kabel der førte et helt andet sted hen.

Find det rigtige interface:
```
show cdp neighbors
```

**Det fysiske interface skal have `no shutdown`.** Subinterfaces følger forælderen —
`no shutdown` inde i et subinterface gør ingenting, hvis forælderen er nede.

**Native VLAN skal matche switchens.** Ellers klager CDP om mismatch:

```
interface GigabitEthernet0/1.99
 encapsulation dot1Q 99 native
exit
```

Ingen IP — native/blackhole-VLAN skal netop ikke kunne bruges til noget.

---

## HSRP — redundant gateway

### Problemet

En PC har én default gateway. Falder routeren ud, kan PC'en intet nå uden for sit eget
subnet — også selvom der står en anden router lige ved siden af. Ingen ændrer gateway
manuelt på hundrede maskiner.

### Løsningen

To routere deler en **virtuel IP** og en virtuel MAC-adresse. Klienterne kender kun den
virtuelle adresse. Den aktive router svarer på den; standby-routeren lytter og overtager
hvis hellos holder op.

| Adresse | Hvem |
|---|---|
| 192.168.10.1 | Virtuel — klienternes gateway |
| 192.168.10.2 | R2's egen |
| 192.168.10.3 | R3's egen |

> [!info] Tal og timere bag HSRP
> Den virtuelle MAC-adresse er ikke tilfældig — den har formen `0000.0C07.ACxx`, hvor
> `xx` er gruppenummeret i hex (gruppe 10 → `0000.0C07.AC0A`). Standard hello-interval
> er 3 sekunder og hold-time 10 sekunder — dør 3 hellos i træk, overtager standby.
> HSRP er Cisco-proprietær; industristandarden hedder **VRRP** og gør stort set det
> samme. Cisco har også **GLBP**, som — modsat HSRP/VRRP — kan lastbalancere trafik
> over *begge* routere samtidig i stedet for at lade den ene stå og vente.

```
! Aktiv router
interface GigabitEthernet0/1.10
 ip address 192.168.10.3 255.255.255.0
 standby 10 ip 192.168.10.1
 standby 10 priority 110
 standby 10 preempt
exit

! Standby - ingen priority, default er 100
interface GigabitEthernet0/2.10
 ip address 192.168.10.2 255.255.255.0
 standby 10 ip 192.168.10.1
 standby 10 preempt
exit
```

**`standby 10`** er gruppenummeret — ét pr. VLAN, så grupperne ikke blandes.
**`priority 110`** gør routeren aktiv; højest vinder, default er 100.
**`preempt`** sørger for at den oprindelige aktive router **tager rollen tilbage** når
den kommer online igen. Uden preempt bliver den der overtog ved at være aktiv.

### Kontrol

```
show standby brief
```

| Kolonne | Betyder |
|---|---|
| State | `Active` eller `Standby` |
| Active | IP på den aktive router — `local` hvis det er dig selv |
| Standby | IP på standby — `unknown` er et problem |

**`Standby unknown` på begge routere** betyder at de ikke kan se hinandens hellos, og
begge derfor tror de er alene. Det er næsten altid Layer 2:

1. Har begge routere en egen IP i subnettet? (HSRP kræver det)
2. Er VLAN'et oprettet på alle switche i kæden?
3. Tillader trunkene mellem switchene VLAN'et?
4. **Er porten fra switch til router en trunk?** ← den der koster mest tid
5. Kan routerne pinge hinandens egne IP'er?

Punkt 4 var vores fejl: `show interfaces Gi0/1 switchport` viste
`Administrative Mode: dynamic auto` og `Operational Mode: static access` — altså en
access-port i VLAN 1. Taggede frames blev droppet, og HSRP-hellos nåede aldrig frem.

### Test failover

```
! på den aktive
interface GigabitEthernet0/1.10
 shutdown
```
Standby skal skifte til `Active`. Åbn igen, og preempt skal give rollen tilbage.

Det er et godt skærmdump til dokumentation — det viser at redundansen virker, ikke kun
at den er konfigureret.

---

## DHCP og relay

### Sådan virker det normalt

DHCP-processen kaldes ofte **DORA** — et huskeord for de fire beskeder:

1. Klienten sender **D**HCPDISCOVER som broadcast — den har ingen IP endnu
2. Serveren svarer **O**HCPOFFER (DHCPOFFER) med et forslag
3. Klienten sender **R**HCPREQUEST (DHCPREQUEST) og beder om netop den adresse
4. Serveren bekræfter med **A**HCPACK (DHCPACK)

Porte: serveren lytter på **UDP 67**, klienten på **UDP 68**.

### Problemet

Broadcasts krydser ikke subnet-grænser. Sidder serveren i et andet net end klienten, hører
den aldrig forespørgslen.

### Relay

```
interface GigabitEthernet0/1.20
 ip helper-address 10.10.10.4
exit
```

Routeren fanger broadcasten, pakker den om til en **unicast** til serveren, og skriver sin
egen interface-adresse i pakken. Den adresse bruger serveren til to ting: at vælge den
rigtige pool, og at vide hvor svaret skal sendes tilbage.

> [!info] `ip helper-address` gør mere end DHCP
> Kommandoen relayer som udgangspunkt **otte** klassiske broadcast-baserede
> UDP-tjenester — DHCP/BOOTP, TFTP, DNS, Time, NetBIOS name/datagram-service og TACACS
> er de mest almindelige. Det er sjældent et problem, men værd at vide hvis du engang
> undrer dig over andet UDP-broadcast-trafik der pludselig dukker op ét sted i
> netværket. Vil du kun relaye DHCP, kan du begrænse det med
> `no ip forward-protocol udp <port>` for de tjenester du ikke vil videresende.

> [!warning] Relay skal på begge HSRP-routere
> Enten kan være aktiv, så begge skal kunne relaye.

> [!warning] Serveren skal kunne svare tilbage
> Det var vores DHCP-fejl. Forespørgslen nåede frem, men serverens gateway pegede på en
> router der ikke var konfigureret endnu — så svaret kom aldrig retur.
>
> Test returvejen eksplicit, fra **serveren**:
> ```
> ping 192.168.20.3
> ```
> Det er relay-adressen svaret skal tilbage til. Kan serveren ikke nå den, får klienten
> intet.
>
> Og routeren mellem server og klient-net **skal kende ruterne** — derfor skal OSPF
> virke, før relay kan virke.

### Pool-opsætning

Gateway i poolen skal være **HSRP's virtuelle adresse**, ikke en routers egen. Ellers
mister klienterne forbindelsen ved failover.

| Felt | Værdi |
|---|---|
| Default Gateway | 192.168.20.1 (virtuel) |
| Start IP | 192.168.20.10 |
| Subnet Mask | 255.255.255.0 |

Start over de adresser infrastrukturen bruger. Ligger switchenes management-IP'er på
.77–.80, så start pool'en på .100.

I Packet Tracer: felterne skal **Add**es. Udfylder du dem og lukker vinduet, gemmes
intet. Retter du en eksisterende pool, skal du trykke **Save** — ikke Add, som laver en
dublet.

---

## OSPF

### Hvad det gør

Routere udveksler information om hvilke net de kender, og regner selv den korteste vej
ud. Tilføjer du et net, spreder det sig automatisk. Falder et link, findes en ny vej.
Alternativet er statiske ruter på hver router — uoverskueligt ved mere end nogle få.

> [!info] Link-state, ikke rygtebørs
> OSPF er en **link-state**-protokol: hver router bygger en fuldstændig kopi af hele
> netværkets topologi (via link-state-annonceringer den flooder til alle naboer) og
> regner selv korteste vej med Dijkstras SPF-algoritme. Det er derfor konvergensen er
> hurtig og pålidelig, i modsætning til ældre **distance-vector**-protokoller (fx RIP),
> hvor routere kun stoler på hvad naboen *siger* er den korteste vej, uden selv at se
> hele billedet.

### Konfiguration

```
router ospf 1
 router-id 3.3.3.3
 passive-interface GigabitEthernet0/1.10
 network 192.168.10.0 0.0.0.255 area 0
 network 10.10.10.0 0.0.0.7 area 0
exit
```

**`ospf 1`** er proces-ID — kun lokalt, behøver ikke matche andre routere.
**`router-id`** sættes manuelt, så output er forudsigeligt. Ellers vælges højeste
interface-IP, som kan ændre sig.
**`network ... area 0`** siger to ting: annoncér dette net, og dan naboskaber på
interfaces i det. Wildcard, ikke subnetmaske.
**Single area** betyder alt i area 0 — fint til mindre netværk.

> [!info] Hello/Dead-timere og cost
> På Ethernet er default hello-interval 10 sekunder og dead-interval 40 sekunder — begge
> **skal matche** mellem to naboer, ellers sidder naboskabet fast i `INIT`. OSPF vælger
> vej ud fra **cost**, som regnes som `reference-bandwidth (default 100 Mbps) ÷
> interface-bandwidth`. På moderne Gigabit- og 10G-links kan flere links derfor få
> samme (minimums-)cost, medmindre du hæver `auto-cost reference-bandwidth` — værd at
> vide, men ikke noget du behøver ændre i et lille lab-net som dette.

### Passive interface

```
passive-interface GigabitEthernet0/1.10
```

Stopper hellos ud af interfacet. Bruges på LAN hvor der kun sidder klienter — der er
ingen routere at danne naboskab med, så hellos er spildt trafik, og de afslører
routing-information over for klienterne.

> [!warning] Passive fjerner IKKE nettet fra OSPF
> `network`-linjen skal blive stående. Fjerner du den, lærer de andre routere aldrig
> LAN'et at kende. Passive = "annoncér nettet, men spild ikke hellos på det".

### Default-rute ud til internettet

Kun kant-routeren kender vejen ud. De øvrige lærer den via OSPF:

```
! på kant-routeren
ip route 0.0.0.0 0.0.0.0 200.200.100.1
router ospf 1
 default-information originate
exit
```

`default-information originate` annoncerer default-ruten til de andre — men **kun hvis
routeren selv har en aktiv default-rute**. Er ISP-linket nede, er den statiske rute
inaktiv, og der annonceres intet. Det var præcis derfor R2 og R3 stod med "Gateway of
last resort is not set": ISP-routerens port var slet ikke konfigureret.

`default-information originate always` annoncerer uanset — brugbart til fejlfinding, men
risikabelt i produktion.

**Outside-nettet skal ikke i OSPF.** Annoncerer du 200.200.100.0/30 internt, tror de
interne routere at de kan nå ISP-nettet direkte, forbi NAT.

### Kontrol

```
show ip ospf neighbor      ! alle skal være FULL
show ip route ospf         ! ruter markeret O
show ip protocols          ! passive interfaces + annoncerede net
```

| State | Betyder |
|---|---|
| `FULL` | Færdig — det du vil se |
| `2WAY` | Hinanden set, endnu ikke udvekslet |
| `LOADING` | Undervejs — vent |
| `INIT` | Ensidig kontakt — ofte native VLAN- eller maskeproblem |

I routingtabellen: `C` = direkte forbundet, `L` = lokal adresse, `O` = lært via OSPF,
`O*E2` = default-rute lært via OSPF, `S*` = statisk default-rute.

---

## NAT og PAT

### Hvorfor

Private adresser (10.x, 172.16–31.x, 192.168.x) kan ikke routes på internettet. NAT
oversætter dem til en offentlig adresse på vejen ud, og tilbage igen på vejen hjem.

**NAT** = én-til-én oversættelse. **PAT** = mange-til-én ved hjælp af portnumre — i
Cisco-syntaks hedder det `overload`. Det er PAT du næsten altid vil have.

> [!info] De fire adressebegreber i `show ip nat translations`
> Cisco bruger fire faste termer for kolonnerne i oversættelsestabellen:
>
> | Term | Betyder |
> |---|---|
> | Inside local | Klientens rigtige, private IP |
> | Inside global | Den offentlige IP/port klienten *ses som* udefra |
> | Outside local | Sådan som den eksterne server ses *indefra* (normalt = outside global) |
> | Outside global | Serverens rigtige, offentlige IP |
>
> Ved PAT er "inside global" den samme delte offentlige IP for alle — det er portnummeret
> (typisk fra det ledige interval **1024–65535**) der gør hver oversættelse unik, og som
> gør at tusindvis af interne klienter kan dele én enkelt offentlig adresse.

### Konfiguration

```
interface GigabitEthernet0/1
 ip nat outside
exit

interface GigabitEthernet0/2
 ip nat inside
exit

ip access-list standard NAT-INSIDE
 permit 192.168.20.0 0.0.0.255
exit

ip nat inside source list NAT-INSIDE interface GigabitEthernet0/1 overload
```

`inside` og `outside` fortæller routeren hvilken retning oversættelsen går.
`interface ... overload` bruger interfacets egen adresse — praktisk hvis den kommer fra
DHCP hos udbyderen.

### ACL'en som adgangskontrol

ACL'en vælger hvem der oversættes. **Implicit deny betyder at alt uden en permit-linje
ikke oversættes** — og uoversat privat trafik kan ikke komme retur fra internettet.

Det er sådan "VLAN 20 må nå ISP, VLAN 10 må ikke" løses: kun VLAN 20 får en
permit-linje.

Symptomforskellen er værd at kende:

| Symptom | Betyder |
|---|---|
| **Timeout** | Ruten findes, men NAT oversætter ikke — spærringen virker |
| **Destination host unreachable** | Ingen rute overhovedet — routing-problem, ikke NAT |

VLAN 10 skal give **timeout**. Får du "host unreachable" fra begge VLAN'er, er
default-ruten ikke nået ud — kig på OSPF, ikke på ACL'en.

> [!warning] Gamle oversættelser overlever ACL-ændringer
> Strammer du ACL'en, bliver eksisterende oversættelser ved med at virke. Tøm tabellen:
> ```
> clear ip nat translation *
> ```
> Fra `#`, ikke config mode.

### Kontrol

```
show ip nat translations       ! aktive oversættelser
show ip nat statistics         ! hits, misses, inside/outside interfaces
show access-lists NAT-INSIDE   ! hvem der faktisk må
```

Tom oversættelsestabel er normalt indtil der sendes trafik. Match-tælleren på ACL'en
afslører hvem der reelt bliver oversat — stiger den for et net du havde spærret, står den
gamle permit-linje der stadig.

---

## NTP

### Hvorfor tid betyder noget

Logs på tværs af enheder kan ikke sammenlignes hvis urene ikke passer. Certifikater
afvises ved for stor afvigelse. Fejlfinding bliver gætteri når tidsstempler ikke kan
korreleres.

### Stratum

Afstanden til en autoritativ kilde. Stratum 0 er et atomur, stratum 1 en server koblet
direkte til det, og hvert hop lægger én til. **Stratum 16 betyder usynkroniseret.**

```
! kilden
ntp master 3

! klienterne
ntp server 200.200.100.1
```

En Cisco-router bliver automatisk NTP-server for andre, så snart den selv er
synkroniseret. `ntp master` er kun nødvendig hvis den skal være autoritativ **uden** en
opstrøms kilde.

> [!info] NTP i det små
> NTP kører over **UDP 123**. I et rigtigt produktionsnet vil man typisk også aktivere
> `ntp authenticate` med en delt nøgle, så en router ikke accepterer tidsopdateringer
> fra en falsk kilde — ikke noget I skal bruge i Packet Tracer, men værd at kende til
> eksamen.

### Kontrol

```
show ntp status
show ntp associations
show clock
```

I associations-tabellen:

| Tegn | Betyder |
|---|---|
| `*` | Aktiv peer — synkroniseret |
| `~` | Konfigureret, men ikke valgt |
| `reach` | Svar-historik — 0 betyder intet svar, 377 er maksimum |
| `offset` | Afstand mellem urene i ms |

### Den store faldgrube

**Cisco IOS træder ikke uret, det slæber det.** Ved en offset over cirka 128 ms justeres
uret i meget små skridt — omkring 0,5 ms pr. sekund. At lukke 5 sekunder tager derfor
timer af simuleret tid, og at lukke 36 år tager uendelig lang tid.

Enheder i Packet Tracer starter i 1990. Derfor skal urene sættes tæt manuelt først, så
NTP kun skal finjustere:

```
clock set 15:50:00 15 September 2026
```

Fra `#`, ikke config mode. Sæt kilde og klient **samme sekund**, ellers starter du med et
hul der skal slæbes.

**To ting mere:**

`clock set` gemmes ikke af `write memory` — uret er ikke en del af konfigurationen og
nulstilles ved genstart.

Sætter du uret **efter** at NTP er kommet i sync, river du det ud af sync igen.

**Fast Forward Time skubber simuleringstiden frem, men urene driver fra hinanden.** NTP
kommer derfor aldrig i mål, fordi målet flytter sig. Lad simuleringen køre i normal
hastighed mens NTP konvergerer.

> [!tip] NTP i Packet Tracer
> Konfigurationen kan være helt korrekt uden at klienten låser. `reach` over 0 sammen med
> korrekt `ref clock` og `st` viser at hierarkiet fungerer — det er det der bedømmes.
> Dokumentér det og gå videre.

---

## Fejlfinding — rækkefølgen der virker

Arbejd nedefra og op. Det sparer enorme mængder tid, fordi et problem i et lavere lag ser
ud som et problem i et højere.

> [!info] Sammenhæng med OSI-modellen
> "Nedefra og op" er bogstaveligt talt OSI-laget: trin 1–2 herunder er lag 1–2 (fysisk +
> switching), trin 3 er stadig lag 2/3 (IP-konfiguration på enheden selv), trin 4 er
> lag 3 (routing), og trin 5–6 er lag 3–4 (filtrering/oversættelse + protokol-specifikt).
> Se [[12 - Network Troubleshooting]] for den fulde symptom/årsag-tabel pr. lag.

### 1. Fysisk og interface

```
show ip interface brief
```

Alt skal være `up / up`. `administratively down` betyder manglende `no shutdown`.

Husk: **subinterfaces virker ikke hvis det fysiske interface er nede.**

### 2. Layer 2

```
show interfaces status
show vlan brief
show interfaces trunk
show interfaces Gi0/1 switchport
show etherchannel summary
show spanning-tree inconsistentports
```

Tjek at VLAN'et findes i databasen på **alle** switche i kæden, at trunkene tillader det,
at native VLAN matcher på begge ender, og — vigtigst — at **porten fra switch til router
faktisk er en trunk.**

`show spanning-tree inconsistentports` skal være tom. Indhold her betyder native
VLAN-mismatch.

### 3. IP-konfiguration på enheden

```
ipconfig            ! på PC
ipconfig /all
```

Læs **tegn for tegn**. Vi har ramt `172.168.1.11` i stedet for `172.18.1.11`, og en maske
på /24 hvor der skulle stå /27. Begge giver symptomer der ser ud som routing-problemer.

Forkert maske er særligt lumsk: klienten tror den er på samme net som destinationen og
sender aldrig til gateway. Ping til egen gateway virker, ping på tværs fejler.

### 4. Routing

```
show ip route
show ip ospf neighbor
show ip protocols
```

Kender routeren vejen? Er naboskaberne `FULL`? Er "Gateway of last resort" sat?

### 5. Filtrering og oversættelse

```
show access-lists
show ip nat translations
show ip nat statistics
```

Match-tællerne viser om trafikken overhovedet rammer reglerne.

### 6. Protokol-specifikt

```
show standby brief
show ntp status
show port-security
show interfaces status err-disabled
```

### Isoleringsteknikken

Fjern midlertidigt ACL eller NAT og test igen. Virker det nu, ligger fejlen i reglen.
Virker det stadig ikke, er problemet et lag længere nede.

```
interface Gi0/1
 no ip access-group MIN-ACL out
```

### Simulation Mode

Packet Tracers stærkeste værktøj og det mest oversete. Filtrér til én protokol, udløs
trafikken, og klik pakken frem hop for hop. Du ser præcis hvilken enhed der dropper den,
og pakkedetaljerne siger hvorfor. Hurtigere end enhver mængde `show`-kommandoer.

---

## De fejl vi faktisk ramte

Værd at læse igen før næste opgave — de koster alle sammen timer.

**Porten fra switch til router var ikke en trunk.** Alt andet var korrekt: VLAN'er
oprettet, EtherChannels oppe, allowed-lister rigtige. Men porten stod `dynamic auto` /
`static access` og droppede taggede frames. HSRP kunne ikke se sin partner. Tjek altid
med `show interfaces <if> switchport`, ikke kun `show interfaces trunk`.

**Subinterfaces på det forkerte fysiske interface.** R2's VLAN-subinterfaces sad på G0/1,
men trunken gik til G0/2. `show cdp neighbors` afgør hvor kablet er.

**ACL'er er additive.** Nye linjer lægges ovenpå de gamle. Den gamle
`permit 192.168.10.0` blev aldrig fjernet, så VLAN 10 kunne fortsat NAT'es.

**Tastefejl i IP-adresser.** `172.168` i stedet for `172.18`. Og en rettelse der kun ramte
IP'en, mens gateway stadig var forkert.

**Forkert subnetmaske på klienter.** /24 hvor der skulle stå /27. Klienten sender aldrig
til gateway, og symptomet ligner et routing-problem.

**DHCP-serverens returvej.** Forespørgslen nåede frem, men serverens gateway pegede på en
router der ikke var konfigureret. Test returvejen fra serveren, ikke kun fra routeren.

**ISP-routeren var slet ikke konfigureret.** Derfor var den statiske default-rute
inaktiv, og `default-information originate` annoncerede intet. Symptomet var "host
unreachable" fra alle VLAN'er.

**`clock set` efter NTP-sync river uret ud igen.** Og uret gemmes ikke af `write memory`.

**Fast Forward Time forhindrer NTP-konvergens.** Urene driver hurtigere fra hinanden end
NTP kan indhente.

**Samme port konfigureret to gange.** S4's Fa0/19-20 stod først som ubrugt i VLAN 99 med
shutdown, derefter som trunk. Trunk-konfigurationen vandt, men `description Unused ports`
hang tilbage.

**Placeholders indsat bogstaveligt.** `interface <porten mod routeren>` giver
`% Invalid input`. `^` peger altid på det første tegn parseren ikke forstod — brug det.

**Packet Tracer taber tegn ved lange indsættelser.** Tag 20–30 linjer ad gangen. Halvdelen
af "% Invalid input"-fejlene skyldes det.

---

## Hurtig kommandoreference

### Se hvad der faktisk står

```
show running-config
show running-config | include vlan
show running-config interface Gi0/1
show ip interface brief
show interfaces status
show cdp neighbors
```

### Fra config mode uden at gå ud

```
do show ip route
do show vlan brief
```

### Ryd op

```
no vlan 67
no interface Gi0/1.67
no ip access-list standard NAVN
default interface Fa0/19          ! nulstil port helt - ikke altid i PT
clear ip nat translation *
clear access-list counters
```

### Start forfra

```
erase startup-config
delete vlan.dat
reload
```

`vlan.dat` gemmer VLAN-databasen separat — `erase startup-config` alene efterlader dine
VLAN'er.

### Gem

```
write memory
```

Ure gemmes ikke. Alt andet gør.

### Rækkefølge der betyder noget

- `service password-encryption` **før** `enable secret` og `username` — ellers krypteres
  de ikke ved oprettelsen
- VLAN skal findes i databasen **før** porte tildeles det
- `spanning-tree mode` før trunks kommer op
- `hostname` og `ip domain-name` før `crypto key generate rsa`
- Statisk default-rute før `default-information originate`

### SSH

```
crypto key generate rsa        ! interaktiv - svar 1024
ip ssh version 2
```

`transport input ssh` på vty lukker for telnet. Uden nøgler kan du hverken bruge det ene
eller det andet.

---

## Ordliste — akronymer der går igen

| Akronym | Betyder |
|---|---|
| ACL | Access Control List — filterregler på router/switch |
| BPDU | Bridge Protocol Data Unit — STP's kontrolbesked mellem switche |
| DORA | Discover, Offer, Request, Ack — DHCP's fire trin |
| HSRP | Hot Standby Router Protocol — Ciscos gateway-redundans |
| VRRP | Virtual Router Redundancy Protocol — den åbne standard, HSRP's modstykke |
| GLBP | Gateway Load Balancing Protocol — Ciscos lastbalancerende gateway-redundans |
| LACP | Link Aggregation Control Protocol — den åbne EtherChannel-standard (802.3ad) |
| PAgP | Port Aggregation Protocol — Ciscos egen EtherChannel-standard |
| NAT/PAT | Network/Port Address Translation — oversætter private til offentlige adresser |
| OSPF | Open Shortest Path First — link-state routingprotokol |
| SPF | Shortest Path First — Dijkstras algoritme, det OSPF regner ruter med |
| STP | Spanning Tree Protocol — forhindrer Layer 2-loops |
| SVI | Switch Virtual Interface — en routet VLAN-grænseflade på en L3-switch |
| TTL | Time To Live — hop-tæller der forhindrer routing-loops (findes ikke på L2) |

---

## Relaterede noter

[[01 - Layer 2 foundation]] · [[02 - HSRP]] · [[03 - OSPF]] · [[04 - NAT and PAT]] ·
[[05 - ACL]] · [[09 - CDP, LLDP & NTP]] ·
[[10 - Byg netvaerket (VLAN, RoaS, static, DHCP, OSPF, NAT)]] ·
[[11 - Network Design]] · [[12 - Network Troubleshooting]]
