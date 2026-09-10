---
tags: [network-2, vpn, tunneling, gre, dmvpn, modul8]
aliases: ["VPN typer", "Tunneling", "GRE", "DMVPN"]
---

# 06 — VPN-typer & tunneling

> Noter fra **Modul 8 (WAN) — VPN**. Se også [[07 - IPsec framework]] og
> [[08a - Opgave-gennemgang (site-to-site IPsec VPN)]].

## Hvad er en tunnel?

Den originale pakke bliver **pakket ind i en ny pakke** (ny ydre IP-header mellem de to
tunnel-endepunkter) og sendt over netværket imellem. Det er forskellen på trafik over et
almindeligt internet-link og trafik i en tunnel.

## VPN — to typer

- **Site-to-site VPN** — enhederne bag VPN-routerne/gateways aner intet om VPN-forbindelsen.
- **Remote-access VPN** — brugerne har en VPN-klient, eller bruger en browser.

## Enterprise vs Service Provider VPN

- **Enterprise VPN** — oprettes og administreres af virksomheden selv, med IPsec og SSL.
  - Site-to-site: IPsec VPN · GRE over IPsec · DMVPN · IPsec VTI
  - Remote access: klient-baseret IPsec · clientless SSL
- **Service Provider VPN** — oprettes og administreres over udbyderens netværk. Udbyderen
  bruger **MPLS** på Layer 2 eller Layer 3.
  - Legacy: Frame Relay, ATM

## DMVPN

Site-to-site IPsec og GRE over IPsec er fine ved **få sites**. Ved **mange sites** bliver det
uoverskueligt at konfigurere alle forbindelser manuelt.

DMVPN (Cisco) opretter **sikre, dynamiske forbindelser mellem mange netværk** (f.eks.
filialkontorer) uden at hver forbindelse skal konfigureres manuelt.

> DMVPN = GRE + NHRP + IPsec. NHRP fungerer som en "dynamisk ARP" for tunnel-interfaces — den
> finder den virkelige IP bag en virtuel tunnel-adresse.

## GRE

En GRE-tunnel er en simpel, fleksibel tunnelprotokol der indkapsler én protokol inde i en
anden — typisk IP over IP. Den pakker de originale pakker (f.eks. OSPF, multicast, IPv6) ind
i en ny IP-pakke og sender dem over netværket. **GRE krypterer ikke.**

| Del | Indhold |
|---|---|
| Ydre IP-header | IP-adresserne på tunnel-endepunkterne |
| GRE-header | info om tunnelen og protokollen indeni |
| Indre pakke | den originale pakke |

Bruges til:
- routingprotokoller over internettet (OSPF, EIGRP)
- i DMVPN
- tunnel hvor IPsec alene ikke kan bruges
