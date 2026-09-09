# CCNA SRWE – Checkpoint Exam Notes

**Course:** Switching, Routing, and Wireless Essentials (SRWE)  
**Purpose:** Quick revision notes from Checkpoint Exam questions  
**Tags:** #CCNA #SRWE #Networking #Cisco

---

## 1. First Hop Redundancy Protocols

### HSRP (Hot Standby Router Protocol)
- Cisco proprietary
- Provides default gateway redundancy
- One **Active** router + one **Standby** router
- Hosts use the **Virtual IP** as gateway

**HSRP Failover Sequence:**
1. The forwarding (Active) router fails
2. Standby router stops seeing Hello messages
3. Standby router becomes the new forwarding router
4. New forwarding router assumes the Virtual IP + Virtual MAC

### GLBP (Gateway Load Balancing Protocol)
- Cisco proprietary
- Provides **both** redundancy **and** load balancing
- Hosts still use one Virtual IP
- Traffic is distributed across multiple routers using different Virtual MACs

**Key Point:**  
When troubleshooting, always configure the host gateway as the **Virtual IP** (not the physical router IPs).

---

## 2. DHCP

### DHCPv4 Process (DORA)
1. **DHCPDISCOVER** – Client looks for servers
2. **DHCPOFFER** – Server offers an IP
3. **DHCPREQUEST** – Client requests the offered IP
4. **DHCPACK** – Server confirms the lease

### Important Commands
| Command                      | What it shows                                      |
|-----------------------------|----------------------------------------------------|
| `show ip dhcp binding`      | IPs currently assigned (leased) to clients         |
| `ip address dhcp`           | Makes a router interface a DHCP **client**         |
| `ip helper-address`         | Configures router as DHCP **relay agent**          |

### DHCP Relay Agent Advantage
A Cisco router configured as a relay agent can provide relay services for **multiple UDP services** (not only DHCP).

### DHCP Pool Calculation Example
- Network: `192.168.234.0/27`
- Total addresses = 32
- Usable hosts = 30
- Reserved for IP phones = 22
- **Left for other hosts = 8**

### DHCP Starvation Attack
- Attacker floods DHCP Discover messages with fake MACs
- Exhausts the entire IP pool
- **Result:** Legitimate clients cannot get an IP address

### DHCP Snooping
- Only ports facing a legitimate DHCP server (or path to it) should be **trusted**
- Client-facing ports remain untrusted

---

## 3. IPv6 Addressing

### SLAAC vs DHCPv6
| Method              | Address Source     | Extra Config (DNS etc.) |
|---------------------|--------------------|-------------------------|
| Pure SLAAC          | SLAAC              | RA options              |
| Stateless DHCPv6    | SLAAC              | DHCPv6                  |
| Stateful DHCPv6     | DHCPv6             | DHCPv6                  |

**Flags in Router Advertisement:**
- **M-flag** (Managed) → Use stateful DHCPv6 for addresses
- **O-flag** (Other) → Use DHCPv6 for other information only

### Duplicate Address Detection (DAD)
After getting an address (SLAAC or DHCPv6):
1. Address starts as **Tentative**
2. Host sends **ICMPv6 Neighbor Solicitation (NS)**
3. If no **Neighbor Advertisement (NA)** is received → address is unique and becomes usable

---

## 4. Port Security

### Violation Modes
| Mode       | Drops packets? | Shuts port? | Sends notification? | Increments counter? |
|------------|----------------|-------------|---------------------|---------------------|
| **Shutdown** (default) | Yes            | Yes         | Yes                 | Yes                 |
| **Restrict** | Yes            | No          | Yes                 | Yes                 |
| **Protect**  | Yes            | No          | **No**              | No                  |

**When to use Protect:**  
Policy says “drop unknown MACs and send **no** notification”.

### Important Show Command
`show port-security interface ...`
- Shows current status, max MACs, sticky MACs, violation count, etc.

### Static MAC Mismatch
If a static secure MAC is configured and a different device connects → **violation** occurs (default = shutdown).

---

## 5. 802.1X Authentication

**Three roles:**
- **Supplicant** → The client device requesting access
- **Authenticator** → The switch (or AP) controlling the port
- **Authentication Server** → Usually a RADIUS server

---

## 6. Wireless Security & Best Practices

### RADIUS Shared Secret
Used only to **encrypt/authenticate messages between the WLC and the RADIUS server**.  
It is **not** used to authenticate end users.

### 5 GHz vs 2.4 GHz
- 5 GHz has **more channels** and is usually **less crowded**
- Better for high-bandwidth services (video streaming)

### Home Wireless AP – Best Practices (Change these three)
1. **AP password** (admin login)
2. **Wireless network password** (WPA2/WPA3 passphrase)
3. **SSID** (network name)

---

## 7. Mitigating VLAN Attacks

**Three recommended techniques:**
1. Set the **native VLAN** to an unused VLAN
2. **Disable DTP** (Dynamic Trunking Protocol)
3. **Enable trunking manually** only on required ports

---

## 8. Discovery Protocols (CDP / LLDP)

**Best Practice:**  
Disable both CDP and LLDP on all interfaces where they are **not required** (especially edge/user ports).

---

## Quick Memory Aids

- **HSRP** → Active + Standby (no load balancing by default)
- **GLBP** → Load balancing + redundancy
- **DORA** → Discover → Offer → Request → Ack
- **DAD** → Neighbor Solicitation → no NA = unique
- **Port Security default** = Shutdown
- **Protect mode** = drop + silent
- **Supplicant** = client
- **Shared secret** = WLC ↔ RADIUS only

---

**End of Notes**  
Good luck on the exam.  
Review the tables and the failover/DAD sequences carefully.

