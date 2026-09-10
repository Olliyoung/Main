---
tags: [brugbare-ting, windows, installation, oobe, cmd]
aliases: ["Windows Installation Useful Commands", "OOBE bypass", "Windows setup CMD"]
---

# Windows installation — nyttige kommandoer

> [!abstract] Hvad & hvorfor
> Genveje under Windows‑opsætning (OOBE) når man vil undgå at logge på med en
> Microsoft‑konto eller komme forbi kravet om internet.

> [!tip] Åbn en kommandoprompt under installationen
> Tryk **Shift + F10**.

```text
:: kom forbi skærmen der kræver en Microsoft-konto (lokal konto i stedet)
start ms-cxh:localonly

:: kom forbi skærmen der kræver internetforbindelse
oobe\bypassnro
```

> [!warning] Bemærk
> - `oobe\bypassnro` genstarter maskinen og tilføjer en "I don't have internet"‑mulighed.
>   Microsoft har fjernet kommandoen i nyere Windows 11‑builds — virker ikke altid længere.
> - Kommandoerne skrives i CMD‑vinduet fra Shift + F10, ikke i et normalt login.
