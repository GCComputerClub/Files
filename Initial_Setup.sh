#!/bin/bash
apt-get install gufw
apt-get install auditd
apt-get install bum
apt-get install fail2ban
apt-get install libpam-cracklib
apt-get install rkhunter
apt-get install clamav
apt-get install clamtk
apt-get update
apt-get upgrade
apt-get dist-upgrade
apt-get autoclean
apt-get autoremove
apt-get install apparmor
apt-get install apparmor-utils
rkhunter --update
auditctl -e 1
aa-enforce /etc/apparmor.d/usr.bin.firefox
sysctl -n net.ipv4.tcp_syncookies
ufw limit ssh/tcp
ufw deny ftp
