---
tags: [h1, storage, raid, ntfs, refs, storage-spaces, iscsi, mcsa]
aliases: ["Chapter 3 MSCA", "RAID noter", "Storage Spaces"]
---

# Lagring og RAID (MCSA kapitel 3)

> [!info] Kilde
> Følg kapitel 3 i *MCSA Windows Server 2016 Complete Study Guide* (eksamen 70‑740/741/742/743).
> Øvelse 2: se `../assets/02_-_Vedligeholdelse_v.22.2.2_1760603277589_0.pdf`.

## 1. Filtyper: NTFS vs ReFS

- **NTFS** er den filsystem‑type Windows bruger mest. Kan alt det smarte: styre rettigheder,
  kryptere filer, komprimere m.m. Meget alsidigt — kan bruges til stort set alt.
- **ReFS** er nyere og bygget til at være mere robust og modstandsdygtig over for fejl og
  datakorruption. Godt til store lagre hvor data ikke må blive beskadiget. Mangler nogle
  NTFS‑features (fx kryptering), så ikke altid det bedste valg.

## 2. Diske, partitioner & volumes

- **MBR vs GPT**
  - MBR er den gamle måde at opdele harddiske på — maks. 2 TB og begrænset antal partitioner.
  - GPT er den nye og bedre måde — håndterer meget store diske og mange partitioner.
- **Basic vs Dynamic disks**
  - Basic disk = "almindelige" diske med partitioner.
  - Dynamic disk = mere avanceret: spejling (mirroring), striping, og at kombinere flere
    diske til ét volume.
- **Volumes og mount points**
  - Et volume er som en "kasse" til dine data.
  - Du kan "montere" et volume inde i en tom mappe i stedet for at give det et drevbogstav —
    smart hvis du løber tør for bogstaver.

## 3. Storage Spaces & Storage Pools

- Tænk på **Storage Pools** som en stor skuffe, hvor du smider flere harddiske sammen.
  Herfra laver du "virtuelle diske" (**Storage Spaces**), som serveren ser som én stor disk.
- Sådan kan data gemmes:
  - **Simple** — gem som de er, ingen beskyttelse, men hurtigt.
  - **Mirror** — gem to kopier; hvis en disk går ned, har du stadig en.
  - **Parity** — lidt som RAID‑5: lidt langsommere, men sparer plads og beskytter data.

## 4. RAID og sikkerhed

| Niveau | Hvad | Bytte |
|---|---|---|
| **RAID 0** | Splitter data på tværs af flere diske | Superhurtigt, men én disk fejler → alt tabt |
| **RAID 1** | Spejler data | Du har en kopi hvis noget går galt |
| **RAID 5** | Hastighed + sikkerhed via "paritet" (en slags backup) | Kan tåle at én disk fejler |

## 5. Netværkslager: iSCSI og Fibre Channel

- **iSCSI** bruger netværket til at give adgang til lagerplads, næsten som om det var en
  lokal disk.
- **Fibre Channel** er en meget hurtig og pålidelig lagringsnetværksteknologi — mest i
  større virksomheder.

## 6. Rettigheder og kvoter

- **NTFS‑rettigheder** styrer hvem der må læse/skrive til filer.
- **Delingsrettigheder** gælder når du deler en mappe ud på netværket.
- Den **strengeste** regel mellem de to gælder altid.
- **Diskkvoter** sætter grænser for hvor meget plads hver bruger må bruge, så én person ikke
  fylder hele harddisken.

## 7. Data deduplikering og tynd provisioning

- **Data deduplikering** finder og fjerner dubletter for at spare plads — godt ved mange ens
  filer.
- **Tynd provisioning** = du "låner" mere plads end du faktisk har; serveren giver mere plads
  når det bliver nødvendigt.

## 8. Replikering

- En kopi af dine data et andet sted kan være en livredder.
- Med **Storage Replica** synkroniserer du data mellem to servere, så de altid er opdaterede.

## 9. Værktøjer til styring

- **Server Manager** — den grafiske måde at styre diske og lagring på.
- **PowerShell** — kommandolinjeværktøj til at automatisere det hele.
- **Disk Management** — nemt værktøj til at opdele og formatere diske.
