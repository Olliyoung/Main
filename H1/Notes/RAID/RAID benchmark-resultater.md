---
tags: [h1, raid, benchmark, storage, øvelse]
aliases: ["RAID.txt", "RAID benchmark", "RAID målinger"]
---

# RAID benchmark-resultater

> [!abstract] Hvad & hvorfor
> Rå måletal fra RAID‑øvelsen (virtuelle diske i lab + en fysisk test). Read/Write i MB/s.
> Se teorien i [[Lagring og RAID (MCSA kapitel 3)]].

## Virtuelle diske (lab)

| Niveau | Diske | Navn | Størrelse | Read | Write |
|---|---|---|---|---|---|
| RAID 0 | 2 | striping | 20 GB | 3569.57 | 2184.35 |
| RAID 0 | 3 | striping | 29 GB | 3560.81 | 2187.86 |
| RAID 0 | 4 | striping | 40 GB | 3550.35 | *(ikke noteret)* |
| RAID 1 | 2 | mirrored volume | 10 GB | 3587 | 274.32 |
| RAID 5 | 3 | RAID 5 | 20 GB | 2450.16 | 218.74 |
| RAID 5 | 4 | RAID 5 | 40 GB | 3121.75 | 512.14 |
| JBOD | 2 | spanned volume | 10 GB | 3574.09 | 2244.63 |
| JBOD | 3 | spanned volume | 29 GB | 3572.82 | 2240 |
| JBOD | 4 | spanned volume | 40 GB | 2128.87 | 520 |

## Fysisk test

> [!note] Deltagere
> Oliver, Nikolaj, Alexander, Viktor, Erik, Kristian

| Niveau | Diske | Størrelse | Read | Write |
|---|---|---|---|---|
| RAID 0 | 2 | 931 GB | 277 | 273 |
| RAID 0 | 3 | 1390 GB | 411 | 405 |
| RAID 0 | 4 | 1862 GB | 549 | 521 |
| RAID 0 | 5 | 2328 GB | 881 | 663 |
| RAID 0 | 6 | 2800 GB | 662 | 616 |
| RAID 0 | 7 | 3250 GB | 943 | 912 |
| RAID 0 | 8 | 1862 GB | 877 | 853 |
| RAID 1 | 2 | 465 GB | 301 | 133 |
| RAID 5 | 3 | 931 GB | 273 | 274 |
| RAID 5 | 4 | 1397 GB | 406 | 412 |
| RAID 5 | 5 | 1862 GB | 545 | 526 |
| RAID 5 | 6 | 2328 GB | 682 | 671 |
| RAID 5 | 7 | 2800 GB | 819 | 800 |
| RAID 5 | 8 | 1630 GB | 765 | 752 |
| RAID 10 | 4 | 931 GB | 537 | 269 |
| RAID 10 | 6 | 1400 GB | 702 | 402 |
| RAID 10 | 8 | 931 GB | 824 | 433 |
| RAID 50 | 6 | 1862 GB | 544 | 302 |

> [!tip] Hvad tallene viser
> - **RAID 0** skalerer læsning/skrivning næsten lineært med antal diske — ingen beskyttelse.
> - **RAID 1 / RAID 5** koster på skrivehastigheden (paritet / dobbeltskrivning).
> - **RAID 10 / 50** ligger midt imellem: bedre beskyttelse, moderat skrivetab.
