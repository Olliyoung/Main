---
tags: [network-2, ipsec, ike, isakmp, diffie-hellman, modul8]
aliases: ["IPsec", "IKE", "ISAKMP", "IPsec framework"]
---

# 07 — IPsec framework

> Noter fra **Modul 8 — VPN**. Se også [[06 - VPN types & tunneling]] og
> [[08a - Opgave-gennemgang (site-to-site IPsec VPN)]].

## De 4 ting IPsec giver

- **Confidentiality (encryption)** — krypterer data før de sendes over netværket.
- **Integrity** — tjekker at data ikke er ændret undervejs; opdages pillen, droppes pakken.
- **Authentication** — tjekker afsenderens identitet, så man taler med den rigtige partner.
  IPsec bruger **IKE (Internet Key Exchange)** til det.
- **Anti-Replay Protection** — opdager og afviser gentagne (replayed) pakker; hjælper mod
  spoofing.

Huskeregel: **C-I-A** (Confidentiality, Integrity, Authentication).

## IPsec Framework — valg pr. trin

Man vælger én ting i hver række (begge peers skal vælge det samme):

| Trin | Muligheder |
|---|---|
| IPsec Protocol | AH · ESP · ESP+AH |
| Confidentiality | DES · 3DES · AES · SEAL |
| Integrity | MD5 · SHA |
| Authentication | PSK · RSA |
| Diffie-Hellman | DH1 · DH2 · DH5 · DH… |

> RSA er en **authentication**-protokol, ikke en krypteringsalgoritme.

## Symmetrisk vs asymmetrisk kryptering

- **Symmetrisk** — samme nøgle til at kryptere og dekryptere. Begge enheder skal kende
  nøglen. Bruges til at kryptere **selve indholdet**. Eksempler: DES og 3DES (ikke længere
  sikre), **AES** (256-bit anbefales til IPsec).
- **Asymmetrisk** — forskellige nøgler til kryptering og dekryptering. At kende den ene nøgle
  gør det ikke muligt at regne den anden ud. Public key-kryptering bruger en privat + en
  offentlig nøgle. Bruges til **digitale certifikater og nøglehåndtering**.

## Diffie-Hellman (DH)

- DH er **ikke** en krypteringsmekanisme og bruges ikke til at kryptere data.
- DH er en metode til **sikkert at udveksle de nøgler**, der bruges til at kryptere data.
- DH er en del af IPsec-standarden.
- AES (samt MD5 og SHA-1) kræver en symmetrisk, delt hemmelig nøgle. RSA bruger forskellige
  nøgler (asymmetrisk).

## Sådan startes en tunnel — trin for trin

1. Vi forudsætter at trafikken skal sendes via VPN.
2. **IKE Phase 1** — authentication af de to ender + åbn en sikker forbindelse til at udveksle
   nøgleoplysninger.
3. **IKE Phase 2** — bliv enige om IPsec SA'erne.
4. Tunnelen oprettes, og data kan sendes igennem.

> **IKE** = Internet Key Exchange. **SA** = Security Association.
> **ISAKMP** = protokol til at oprette Security Associations og kryptonøgler.
> `crypto isakmp policy` = Phase 1-politikken.
