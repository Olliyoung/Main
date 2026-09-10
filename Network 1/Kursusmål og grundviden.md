---
tags: [network-1, ccna, srwe, kursusmål, grundviden, boot, svi, vlan]
aliases: ["Målpinde", "Boot-sekvens", "SVI grundviden"]
---

# Kursusmål og grundviden (Network 1 / SRWE)

> [!info] Kilde
> Fra `Oversigt DIV/Network.md`. Kommandoer ligger i [[00 - Cheat sheet|Cisco commands]];
> teori i [[01 - Routing & static routes|CCNA theory]].

## Målpinde

> [!abstract] Lærlingen kan…
> - konfigurere **VLAN'er og Inter‑VLAN‑routing** på routere og L3‑switche
> - konfigurere **redundans** på et switched netværk med **STP og EtherChannel**
> - konfigurere **dynamisk adressetildeling i IPv6**‑netværk
> - konfigurere **WLAN'er** med en WLC og grundlæggende **L2‑sikkerhed**
> - konfigurere **switch‑sikkerhed** for at mindske LAN‑angreb
> - konfigurere **IPv4 og IPv6 statisk routing** på routere og/eller L3‑switche
> - **fejlfinde inter‑VLAN‑routing** på Layer 3‑enheder
> - **fejlfinde EtherChannel** på L2‑netværk
> - forklare hvordan man sikrer **oppetid og tilgængelighed** af IP‑netværk med dynamisk
>   adressering og **first‑hop redundansprotokoller**

## Boot-sekvens for en Cisco switch/router

| Trin | Hvad sker der |
|---|---|
| 1 | **POST** (i ROM) — kontrollerer CPU, RAM og den del af flash der indeholder filsystemet |
| 2–3 | **Bootloader** (i ROM) — low‑level CPU‑init: finder hvor hukommelsen sidder, hvor meget og hvor hurtig |
| 4 | Bootloader initialiserer **flash‑filsystemet** hvor IOS ligger |
| 5 | Bootloader finder og indlæser et **IOS‑image i RAM** og afgiver kontrollen til IOS (+ evt. startup‑config) |

> [!tip] Kort udgave
> Trin 1: POST (er alt OK?) → Trin 2–4: Bootloader fra ROM (finder hukommelse, gør
> filsystemet klar) → Trin 5: IOS‑image + evt. opstartskonfiguration ind i RAM.

## Hvorfor en switch skal have en SVI for at kunne styres

**En switch er en Layer 2‑enhed.** Der sidder et NIC på motherboardet, men intet RJ45‑stik
koblet direkte til et management‑NIC.

- **SVI (Switch Virtual Interface / VLAN‑interface):** her lægger du Layer 3‑adressen
  (IP + subnetmaske), så du kan styre switchen.
- **VLAN:** et virtuelt/logisk LAN — én fysisk switch kan opføre sig som flere separate
  switche.
  - Alle switche fødes med **VLAN 1** (kan ikke slettes).
  - Som standard ligger alle porte og management i VLAN 1.
  - **Best practice:** brug aldrig VLAN 1 til management — opret et separat management‑VLAN.

> [!warning] En SVI (fx VLAN 99) viser kun "up/up" når…
> 1. VLAN'et er oprettet, **og**
> 2. mindst én port er tilknyttet det VLAN **og** der sidder en enhed på porten.

> [!note] Husk kæden
> Switch = L2 → management kræver en SVI → SVI hører til et VLAN → VLAN 1 er standard
> (undgå det til management).
