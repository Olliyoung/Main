---
tags: [h1, security, cia, physical-security, risk-management, mcsa]
aliases: ["Understanding Security Layers", "CIA triad", "Physical security"]
---

# Understanding security layers

> [!abstract] What & why
> The groundwork before securing anything: the **CIA triad** (the three goals of any
> security program) and **physical / layered security** (defence in depth — controlling who
> can physically reach a resource). Notes from MCSA study + class.

## The CIA triad

> [!info] Confidentiality
> Keeping information, networks and systems safe from unauthorized access. Everyday example:
> if your job handles sensitive data, you can't discuss it with people who aren't
> authorized. Backed by strong encryption and/or strong authentication. Think of it as a
> secret only a few people are allowed to know — like a doctor's duty toward your records.

> [!info] Integrity
> Doing the right thing even when no one is watching: protecting data from being changed by
> people who shouldn't change it, and keeping the protection as intended. Example: checking
> an ISO's checksum after download tells you whether the file got corrupted.

> [!info] Availability
> Information or a system is reachable when someone needs it. Availability problems can be
> **accidental** (power outage, hardware failure, natural disaster) or **deliberate** (an
> attacker overloading a system). First step when something goes down: work out whether it
> was an accident or deliberate — each is handled differently.

## Physical premises — three logical areas

### External perimeter (outside the building)

- Checking cars at the gate, guard patrol frequency
- Reporting suspicious people or abandoned bags
- Logging cars, visitors, entries and exits

### Internal perimeter (inside, but not the secure rooms yet)

Divide space so only the right people reach where they need to — **least privilege applied
to physical space**.

- Finance staff only in finance, HR only in HR, IT only in IT rooms
- Tools: guard patrols, smoke detectors, turnstiles, mantraps (one‑person airlock doors)
- Processes: visitor sign‑in, escorting visitors, delivery rules, rules for personal
  laptops/phones, equipment‑removal rules, when doors stay locked/unlocked

### Secure areas (high-security rooms)

- Examples: data centers, server rooms, research labs, network/phone rooms
- Tools: badge readers, keypads, biometrics (fingerprint, retina, voice), security doors,
  cameras, X‑ray scanners, metal detectors, intrusion detectors (infrared, microwave,
  ultrasonic)
- Processes: who may enter, how they get access, cameras/guards/alarms

> [!note]
> Small offices sometimes use remote monitoring because no one is on site at night.

![[Pasted image 20251127092737.png]]

## Computer security (physical only)

| Type | Notes | How to secure |
|---|---|---|
| **Servers** | Run important apps/sites, expensive | Lock in server rooms / data centers; else security cables, locked cabinets/racks |
| **Desktops** | Offices, schools, homes; cheap | Usually just cable locks |
| **Mobile computers** | Laptops, tablets, phones; easy to steal | Extra protection needed (below) |

### Securing laptops physically

- Docking stations with locks · laptop security cables · laptop safes
- Theft‑recovery software · laptop alarms (trigger on movement or a cut cable)

### Phones & PDAs

Harder to secure physically — use strong passwords, encryption, remote wipe, built‑in GPS.

> [!tip] Best practices for mobile devices
> Keep devices with you · never leave them visible in a car · use the trunk if you must
> leave them · use hotel safes when travelling.

## Removable devices (USB, SD, external drives)

**Uses:** backups, extra storage, moving files, running apps, music players.

**Security issues:** loss (easy to lose a USB stick), theft, espionage (USB disguised as
pens, watches, etc.).

> [!tip] Protection
> Encryption · authentication · train users not to store confidential data carelessly · keep
> devices on you or locked away. **Don't try to ban all small devices — protect the data
> instead (least privilege).**

## Keyloggers

Capture what you type (passwords, card numbers…).

| Type | What it is | Defence |
|---|---|---|
| Physical | Plugged between keyboard and PC | Inspect the cable — anything "extra", don't use the PC |
| Software | Malware | Updated antivirus, UAC, firewalls |
| Wireless sniffer | Captures wireless keystrokes | Use encrypted wireless keyboards |

## Risk management

- **Risk** = the probability that a bad event occurs.
- Four responses: **Avoidance** (don't do the risky thing) · **Acceptance** (live with it) ·
  **Mitigation** (reduce it) · **Transfer** (insurance, outsourcing).
- **Attack surface** = every method/avenue an attacker can use to get in. Bigger surface =
  greater risk.
- **Social engineering** — the key defence is employee awareness.
- **Principle of least privilege** — a user, system or application gets no more privilege
  than needed to do its job.

> [!summary] What I learned
> - You need the standard security concepts before you can secure an environment.
> - **CIA** = confidentiality, integrity, availability — the core goals of an information
>   security program.
> - Threat and risk management = identifying, assessing and prioritizing threats and risks;
>   a risk is the probability an event occurs; four responses: avoidance, acceptance,
>   mitigation, transfer.
> - Physical security uses **defence in depth / layered security** to control who can
>   physically access resources, across the external perimeter, internal perimeter and
>   secure areas.
> - Computer security = the processes, procedures, policies and technologies protecting
>   computer systems.
> - Mobile and mobile‑storage devices are among the biggest challenges because of their size
>   and portability.
> - A keylogger is a physical or logical device that captures keystrokes.
