
**Confidentiality**
	Confidentiality is a concept we deal with in our everyday life. For example, if you have a job where you handle sensitive data, you’re not allowed to talk about it with people who aren’t authorized. It can also mean strong encryption and/or strong authentication. You can think of confidentiality like a secret that only a few people are allowed to know. For example, your doctor works with sensitive information about you and has a duty to keep it confidential.


**Integrity**
	Integrity, in simple terms, means doing the right thing even when no one is watching. It’s about protecting data from being changed by people who shouldn’t be changing it, and keeping the protection the way it’s supposed to be. For example, when you download an ISO, you can check its integrity to see if anything got corrupted during the download. It’s smart to do, because it lets you know if your ISO file is damaged or not.


**Availability**  
	Availability means that information or a system is reachable when someone needs it. If a user tries to access something, it should be working and ready. Problems with availability can happen by accident, like power outages, hardware failures, or natural disasters. They can also happen on purpose, like when someone attacks a system to overload it and make it stop responding. When something goes down, you first need to figure out if it was an accident or something done deliberately, because each one is handled differently.



## **Internal Perimeter – What It Means**

This is the inside of the building, but not the most secure areas yet. Here you divide spaces so only the right people can go where they need to.

**Examples:**

- Finance people only enter finance.
    
- HR only in HR.
    
- IT only in IT rooms.
    

**Tools used inside:**

- Guard patrols
    
- Smoke detectors
    
- Turnstiles
    
- Mantraps (one person at a time airlock-style doors)
    

This follows the **principle of least privilege** but for physical spaces.

---

# **Secure Areas**

These are the “high-security rooms” inside a company.

**Examples of secure areas:**

- Data centers
    
- Server rooms
    
- Research labs
    
- Network/phone rooms
    

**Security tools for these areas:**

- Badge readers
    
- Keypads
    
- Biometrics (fingerprint, retina, voice)
    
- Security doors
    
- Cameras
    
- X-ray scanners
    
- Metal detectors
    
- Intrusion detectors (infrared, microwave, ultrasonic)
    

---

# **Site Security Processes (Rules That Support Technology)**

Security is not only the tech — it’s also the rules and processes.

### **External Perimeter Processes (Outside the building)**

- How guards check cars at the gate
    
- How often guards walk around
    
- How to report suspicious people or abandoned bags
    
- Logging cars, visitors, entries, exits
    

### **Internal Perimeter Processes (Inside building but not secure rooms)**

- Visitor sign-in
    
- Escorting visitors
    
- Delivery rules
    
- Rules for bringing personal laptops/phones
    
- Equipment removal rules
    
- When doors stay locked/unlocked
    

### **Secure Area Processes**

- Who is allowed inside the data center
    
- How they get access (keys, biometrics, badges)
    
- Cameras, guards, alarms, etc.
    

**Note:**  
Small offices sometimes use remote monitoring because no one is there at night.


![[Pasted image 20251127092737.png]]

---

# **Computer Security (Physical Security Only)**

Three main types of computers you secure differently:

### **1. Servers**

- Run important apps/websites
    
- Expensive
    
- Must be locked in server rooms or data centers  
    If not possible:
    
- Use computer security cables
    
- Lock them in server cabinets/racks
    

### **2. Desktops**

- Found in offices/schools/homes
    
- Usually secured with simple cable locks
    
- Not as heavily protected because they’re cheap compared to servers
    

### **3. Mobile Computers**

- Laptops, tablets, phones
    
- Easy to steal → need extra protections
    

---

# **Mobile Device Security (Your Laptop/Phone, etc.)**

Mobile devices are a big challenge.

### **Ways to physically secure laptops:**

- Docking stations with locks
    
- Laptop security cables
    
- Laptop safes
    
- Theft-recovery software (track stolen devices)
    
- Laptop alarms (go off if moved or cable is cut)
    

### **Phones & PDAs**

Harder to secure physically, but you can:

- Use strong passwords
    
- Enable encryption
    
- Allow remote wipe
    
- Use built-in GPS for tracking
    

---

# **Best Practices for Mobile Devices**

- Keep your devices with you
    
- Never leave them visible in cars
    
- Use the car trunk if you must leave them
    
- Use hotel safes when traveling
    

---

# **Removable Devices (USB, SD Cards, External Drives)**

Things like USB sticks, SD cards, external drives.

**Uses:**

- Backups
    
- Extra storage
    
- Moving files
    
- Running apps
    
- Music players use them too
    

**Security issues with removable storage:**

1. **Loss** (easy to lose USB sticks)
    
2. **Theft**
    
3. **Espionage** (USB disguised as pens, watches, etc.)
    

### **Protection Tips**

- Use encryption
    
- Use authentication
    
- Teach users not to store confidential stuff carelessly
    
- Keep devices on you
    
- Lock them in safe/drawers if not
    

**Main idea:**  
Don’t try to ban all small devices.  
**Instead protect the data** → least privilege.

---

# **Keyloggers**

Keyloggers capture what you type (passwords, credit cards, etc.)

### **Types**

- **Physical keyloggers:** Plugged between keyboard and PC
    
- **Software keyloggers:** Malware
    
- **Wireless keyboard sniffers:** Capture wireless keystrokes
    

### **Defenses**

- **Physical:** Look at the cable — if something is “extra,” don’t use the PC
    
- **Software:** Updated antivirus, UAC, firewalls
    
- **Wireless:** Use encrypted wireless keyboards
    

---

# **CIA Summary (The Big 3 of Security)**

- **Confidentiality** – only allowed people can access the data
    
- **Integrity** – data cannot be changed without permission
    
- **Availability** – users can access what they need when they need it
    

---

# **Risk Management Notes**

- Risk = chance something bad happens
    
- Four responses:
    
    - **Avoidance** (don’t do the risky thing)
        
    - **Acceptance** (live with it)
        
    - **Mitigation** (reduce it)
        
    - **Transfer** (insurance, outsourcing)
        
- Attack surface = all the ways someone can attack you. Bigger surface = more danger.
    
- Social engineering → biggest defense is employee awareness.

## **What i Learned**

Before you can start securing your environment, you need to have a fundamental understanding of the standard concepts of security.

CIA, short for confidentiality, integrity, and availability, represents the core goals of an information security program.

Confidentiality deals with keeping information, networks, and systems secure from unauthorized access.

One of the goals of a successful information security program is to ensure integrity, or that information is protected against any unauthorized or accidental changes.

Availability is defined as the characteristic of a resource being accessible to a user, application, or computer system when required.

Threat and risk management is the process of identifying, assessing, and prioritizing threats and risks.

A risk is generally defined as the probability that an event will occur.

Once you have prioritized your risks, there are four generally accepted responses to these risks: avoidance, acceptance, mitigation, and transfer.

The principle of least privilege is a security discipline that requires that a user, system, or application be given no more privilege than necessary to perform its function or job.

An attack surface consists of the set of methods and avenues an attacker can use to enter a system and potentially cause damage. The larger the attack surface of an environment, the greater the risk of a successful attack.

The key to thwarting a social engineering attack is employee awareness. If your employees know what to look out for, an attacker will find little success.

Physical security uses a defense in depth or layered security approach that controls who can physically access an organization’s resources.

Physical premises can be divided into three logical areas: the external perimeter, the internal perimeter, and secure areas.

Computer security consists of the processes, procedures, policies, and technologies used to protect computer systems.

Mobile devices and mobile storage devices are among the biggest challenges facing many security professionals today because of their size and portability.

A keylogger is a physical or logical device used to capture keystrokes