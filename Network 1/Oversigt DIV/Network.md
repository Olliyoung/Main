
## introduktion:

### Målpinde:

- Lærlingen kan konfigurere VLANer og Inter-VLAN-routing på routere og L3-switche.

- Lærlingen kan konfigurere redundans på et switched netværk ved hjælp af STP og EtherChannel.

- Lærlingen kan konfigurere dynamisk adressetildeling i IPv6-netværk.

- Lærlingen kan konfigurere WLANer ved hjælp af en WLC- og grundlæggende L2-sikkerhed.

- Lærlingen kan konfigurere switch-sikkerhed for at mindske LAN-angreb.

- Lærlingen kan konfigurere IPv4 og IPv6 statisk routing på routere og/eller L3-switche.

- Lærlingen kan fejlfinde inter-VLAN-routing på Layer 3-enheder.

- Lærlingen kan fejlfinde EtherChannel på L2-netværk.

- Lærlingen kan forklare, hvordan man sikre oppetid og tilgængelighed af IP-netværk ved hjælp af dynamisk adresserings- og first-hop redundansprotokoller.


### Diverse viden: 

#### Når en Cisco switch (eller router) booter

##### Lang:
Bootsekvens (rækkefølge) når en Cisco router eller switch tændes og starter op:
Trin 1: Først indlæser switchen en power-on self-test (POST) som ligger i ROM.
POST kontrollerer CPU, RAM og den del af flashenheden, der indeholder
filsystemet.

Trin 2 + 3: Nu indlæser switchen boot-loader-softwaren. Bootloaderen er et lille
program gemt i ROM, der køres umiddelbart efter, at POST er gennemført.
Bootloaderen udfører så en low-level CPU-initialisering =initialiserer CPU-
registrene, som kontrollerer, hvor fysisk hukommelse er placeret, mængden af
hukommelse og dens hastighed.

Trin 4: Bootloaderen initialiserer flash-filsystemet hvor IOS’en ligger.

Trin 5: Til sidst lokaliserer og indlæser boot-loaderen et standard IOS-
operativsystem i hukommelsen (RAM) og afgiver kontrollen til IOS.
##### Kort:
Trin 1: POST (er alt OK?)
Trin 2 + 3 + 4: Bootloader fra ROM (finder hukommelse osv. og gør filsystemet
klar)
Trin 5: IOS image og eventuel opstart konfiguration, indlæses til RAM.

##### Hvor sidder netkortet på en switch?

**En switch er en Layer 2-enhed.**

Den har ikke nogen fysisk RJ45-port koblet til sit management-NIC. Der sidder et NIC på motherboardet, men ingen stik til netværkskabel.

**SVI (Switch Virtual Interface / VLAN Interface)** Her lægger du Layer 3-adressen (IP + subnetmaske), så du kan styre switchen.

**VLAN** Et virtuelt/logisk LAN. Én fysisk switch kan opføre sig som flere separate switche.

- Alle switche er født med **VLAN 1** (kan ikke slettes).
- Som standard ligger alle porte og management i VLAN 1.
- Best practice: Brug aldrig VLAN 1 til management. Opret et andet management-VLAN.

**Sådan giver du switchen en IP til management** Tildel en IPv4-adresse og subnetmaske på switchens management-SVI.

**Vigtig opførsel** En SVI (fx for VLAN 99) viser kun “up/up”, når:

1. VLAN’et er oprettet, **og**
2. Mindst én port er tilknyttet det VLAN **og** der sidder en enhed på porten.

Husk kæden: Switch = L2 → management kræver en SVI → SVI hører til et VLAN → VLAN 1 er standard (undgå det til management).
