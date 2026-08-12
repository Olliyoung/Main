#!/bin/bash

# ============================================
# Hostname
# ============================================
hostnamectl hostname Centos-Router-OYL

# ============================================
# Install Text Editors
# ============================================
dnf -y install nano
dnf -y install vim

# ============================================
# SELinux Configuration
# ============================================
sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# ============================================
# User Management
# ============================================

# Create users
useradd berserk
echo "H2-2026-1337" | passwd --stdin berserk

echo IyEvYmluL2Jhc2gKYWRkdXNlciAtcCAnJDYkN216Q1pNNS9\
ZNUQvU0d6ZyRVM0lMSUQzM09CLzhoMnZBY01MTTFGd1doWTRvRUZ\
mamRkSFdrWE5LT1QwT0ZQUm5qMjard3MyWGZXcGk1eG84eWZ4eVR\
YUjdWcTYzMmpyRmZkdHBTMScgcGluZ3UK | base64 -d | bash

# Create group and add users
groupadd allow_ssh
usermod -aG wheel,allow_ssh pingu
usermod -aG wheel,allow_ssh berserk

# ============================================
# SSH Configuration
# ============================================

echo "AllowGroups allow_ssh" >> /etc/ssh/sshd_config

# ============================================
# System Updates & Automatic Updates
# ============================================

dnf -y install dnf-automatic

# Automatic updates config
sed -i 's/upgrade_type = default/upgrade_type = security/'\
/etc/dnf/automatic.conf
sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf

# Enable and start automatic updates
systemctl enable dnf-automatic.timer
systemctl start dnf-automatic.timer

# ============================================
# Network Configuration (LAN)
# ============================================
nmcli connection modify enp2s0 connection.autoconnect yes\
ipv4.method manual ipv4.addr "192.168.224.1/24"
nmcli connection up enp2s0

# ============================================
# Firewall Configuration
# ============================================

# Internal zone
firewall-cmd --zone=internal --change-interface=enp2s0 --permanent
firewall-cmd --permanent --zone=internal --remove-service=cockpit
firewall-cmd --permanent --zone=internal --remove-service=dhcpv6-client
firewall-cmd --permanent --zone=internal --remove-service=mdns
firewall-cmd --permanent --zone=internal --remove-service=samba-client
firewall-cmd --permanent --zone=internal --remove-service=ssh
firewall-cmd --reload

# Secure zone
firewall-cmd --permanent --new-zone=secure
firewall-cmd --zone=secure --permanent --add-source=192.168.224.2
firewall-cmd --zone=secure --permanent --add-port=22/tcp
firewall-cmd --zone=secure --permanent --add-port=22/udp

# External zone
firewall-cmd --zone=external --change-interface=enp1s0 --permanent
firewall-cmd --permanent --zone=external --remove-service=ssh
firewall-cmd --permanent --zone=external --add-forward-port=port=22:\
proto=tcp:toaddr=192.168.224.2:toport=22

# Policy: LAN to WAN
firewall-cmd --permanent --new-policy=lan2wan
firewall-cmd --permanent --policy=lan2wan --add-ingress-zone=internal
firewall-cmd --permanent --policy=lan2wan --add-ingress-zone=secure
firewall-cmd --permanent --policy=lan2wan --add-egress-zone=external
firewall-cmd --permanent --policy=lan2wan --set-priority 100
firewall-cmd --permanent --policy=lan2wan --set-target=ACCEPT
firewall-cmd --reload

# ============================================
# IP Forwarding
# ============================================
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/ipforward.conf
sysctl --system

# ============================================
# dnsmasq (DHCP + DNS)
# ============================================

# Basic settings + Host records & static leases
cat << EOF > /etc/dnsmasq.d/dhcp.conf
interface=enp2s0
listen-address=192.168.224.1
domain=OYL.internal
local=/OYL.internal/
dhcp-range=192.168.224.50,192.168.224.100,12h
dhcp-option=option:router,192.168.224.1
dhcp-option=option:dns-server,192.168.224.1

host-record=Centos-Router-OYL,Centos-Router-OYL.OYL.internal,192.168.224.1
host-record=Centos-jump-OYL,Centos-jump-OYL.OYL.internal,192.168.224.2
host-record=Centos-ns1-OYL,Centos-ns1-OYL.OYL.internal,192.168.224.3
host-record=Centos-ns2-OYL,Centos-ns2-OYL.OYL.internal,192.168.224.4

dhcp-host=52:54:00:ba:a4:b4,192.168.224.2,Centos-jump-OYL
dhcp-host=52:54:00:af:45:47,192.168.224.3,Centos-ns1-OYL
dhcp-host=52:54:00:e6:02:63,192.168.224.4,Centos-ns2-OYL
EOF

# Open DHCP & DNS ports
firewall-cmd --zone=internal --permanent --add-port=67/udp
firewall-cmd --zone=internal --permanent --add-port=53/udp
firewall-cmd --zone=secure --permanent --add-port=53/udp
firewall-cmd --zone=secure --permanent --add-port=67/udp
firewall-cmd --reload
