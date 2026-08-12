#! /bin/bash

init() {
  # update packages
  dnf -y upgrade

  # set hostname
  hostnamectl hostname --static  Centos-jump-OYL

  # install dnf-automatic
  dnf -y install dnf-automatic

  # install nano og vim
  dnf install nano vim -y
  
}

brugere() {
  # create users
echo IyEvYmluL2Jhc2gKYWRkdXNlciAtcCAnJDYkN216Q1pNNS9\
ZNUQvU0d6ZyRVM0lMSUQzM09CLzhoMnZBY01MTTFGd1doWTRvRUZ\
mamRkSFdrWE5LT1QwT0ZQUm5qMjard3MyWGZXcGk1eG84eWZ4eVR\
YUjdWcTYzMmpyRmZkdHBTMScgcGluZ3UK | base64 -d | bash

    useradd berserk-jump
    echo "H2-2026-1337" | passwd --stdin berserk-jump

  # create group + add members
    groupadd allow_ssh
    usermod -aG wheel,allow_ssh pingu
    usermod -aG wheel,allow_ssh berserk-jump

}

selinux() {

  # set SELinux permissive
    sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

}

allow_ssh() {

  # allow SSH group
    echo "AllowGroups allow_ssh" >> /etc/ssh/sshd_config

}

dnf-automatic() {

  # Automatic updates config
    sed -i 's/upgrade_type = default/upgrade_type = security/'\
    /etc/dnf/automatic.conf
    sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf

  # Enable and start automatic updates
    systemctl enable dnf-automatic.timer
    systemctl start dnf-automatic.timer

}

firewalld() {

  # Internal zone / Add SSH port / Remove services
    firewall-cmd --permanent --zone=internal --change-interface=enp1s0
    firewall-cmd --permanent --zone=internal --remove-service=cockpit
    firewall-cmd --permanent --zone=internal --remove-service=dhcpv6-client
    firewall-cmd --permanent --zone=internal --remove-service=mdns
    firewall-cmd --permanent --zone=internal --remove-service=samba-client
    firewall-cmd --permanent --zone=internal  --add-port=22/tcp
    firewall-cmd --reload

}

main () {

  # main funktion
if ! $(rpm --quiet -q nano); then
  init
fi

  # bruger funktion
if ! $(id berserk-jump); then
  brugere
fi
  
  # SELinux funktion
if ! $(grep -q "SELINUX=permissive" /etc/selinux/config); then
selinux
fi

  # Allow_SSH funktion
if ! $(grep -q "AllowGroups allow_ssh"  /etc/ssh/sshd_config); then
allow_ssh
fi

  # dnf-automatic funktion
if ! $(rpm --quiet -q dnf-automatic); then
  dnf-automatic
fi
  # firewalld funktion
if ! $(firewall-cmd --list-all --zone=internal | grep enp1s0); then
  firewalld
fi
}

main

reboot