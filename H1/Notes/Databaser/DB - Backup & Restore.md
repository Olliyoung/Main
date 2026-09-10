---
tags: [h1, database, sql-server, backup, restore]
aliases: ["Backup og restore", "SQL backup typer"]
---

# DB — Backup & Restore

> [!abstract] Hvad & hvorfor
> Oversigt over backup‑typerne i SQL Server og hvordan de spiller sammen ved en restore.

## Backup-typer

> [!info] Full backup
> Backup af hele databasen, som den så ud umiddelbart før backuppen afsluttede. Godt at tage
> en full backup en gang imellem (grundlag for rollback).

> [!info] Differentiel backup
> Baseret på den nyeste forudgående full backup (kaldes **basen**). Indfanger kun data der er
> ændret efter basen.

> [!info] Transaktionslog-backup
> Backup af transaktionsloggen — fanger alle ændringer siden sidste log‑backup, så du kan
> gendanne til et bestemt tidspunkt (point‑in‑time).

> [!info] Copy-only backup
> Indeholder det samme som en "normal" backup, men **bryder ikke kæden** af backups (ændrer
> ikke basen for differentielle / logsekvensen).

> [!info] Partiel backup / fil-backup
> I SQL Server kan du også tage backup af enkelte datafiler eller filgrupper.

## Sådan hænger de sammen ved restore

1. Gendan den seneste **full backup** (basen).
2. Gendan den seneste **differentielle** backup (hvis der er en).
3. Gendan **transaktionslog‑backups** i rækkefølge frem til det ønskede tidspunkt.

![SQL backup-typer](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Flitextension.com%2Fblog%2Fwp-content%2Fuploads%2F2024%2F11%2Ftypes-of-sql-backup.webp&f=1&nofb=1&ipt=5ab2dfd31bd3cc070ddf59758cfe86cc80cc8a952f7f624a1972d7b8b49d8e32)

> [!note] Øvelsesfiler
> `.bak`‑filer og skemaer ligger i `backup/` og `Opgaver/`.
