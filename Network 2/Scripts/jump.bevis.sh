#!/bin/bash
#
# Script til at generere en bevis-fil for jump serveren.
# Skal først bruges efter jump.sh scriptet er kørt.
#
#
# Author: Martin Beck
# Version 26.04
#
#=============================================
#Global Variables
filename="$(hostname --short).bevis.txt"
bevis_folder="/tmp/bevis"

egen_bruger=berserk
#=============================================


init () {
  if [[ -e "${bevis_folder}/${filename}" ]]; then
    rm "${bevis_folder}/${filename}"
  fi

  if [[ ! -d "${bevis_folder}" ]]; then
    mkdir -p "$bevis_folder"
  fi
}


ny_overskrift () {
  echo -e "\n\n\n"
  echo "#####################################################################"
  echo "### $1"
  echo "### Udskrevet: $(date +'%Y-%m-%d %H:%M:%S')"
  echo "#####################################################################"
}


bevis_init () {
  ny_overskrift "Bevis af init"
  rpm -qa nano vim-enhanced mc dnf-automatic
  hostnamectl status
}


bevis_brugere () {
  ny_overskrift "Bevis af brugere"
  id $egen_bruger
  id pingu
}


bevis_selinux () {
  ny_overskrift "Bevis af SELinux"
  sestatus
}


bevis_allow_ssh () {
  ny_overskrift "Bevis af SSH gruppe tilladelse"
  echo "/etc/ssh/sshd_config :"
  grep "AllowGroups" /etc/ssh/sshd_config
}


bevis_dnf_automatic () {
  ny_overskrift "Bevis af DNF automatisk opsættning"
  echo "/etc/dnf/automatic.conf :"
  grep "upgrade_type" /etc/dnf/automatic.conf
  grep "apply_updates" /etc/dnf/automatic.conf
}


bevis_firewalld () {
  ny_overskrift "Bevis af Firewalld"
  nmcli
  firewall-cmd --list-all --zone=internal
}


main () {
  init

  output=${bevis_folder}/${filename}

  bevis_init >> $output
  bevis_brugere >> $output
  bevis_selinux >> $output
  bevis_allow_ssh >> $output
  bevis_dnf_automatic >> $output
  bevis_firewalld >> $output

  echo "Beviser er skrevet til filen: $output"
}

if [ "$EUID" -ne 0 ]
  then echo -e "\033[31mKør Scriptet som root eller med sudo.\033[0m"
  exit
fi

main
