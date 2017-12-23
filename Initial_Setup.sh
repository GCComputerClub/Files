#!/bin/bash
apt-get install gufw auditd audispd-plugins bum fail2ban libpam-cracklib rkhunter clamav clamtk openssl clamav-daemon
apt-get update
apt-get upgrade
apt-get dist-upgrade
apt-get autoclean
apt-get autoremove
apt-get install apparmor apparmor-utils
rkhunter --update
auditctl -e 1
aa-enforce /etc/apparmor.d/usr.bin.firefox
sysctl -n net.ipv4.tcp_syncookies
ufw limit ssh/tcp
ufw deny ftp

mkdir /home/user/Desktop/backUp
cat /etc/sysctl.conf > /home/user/Desktop/backUp/$(ls /etc/sysctl.conf)
cat /etc/login.defs > /home/user/Desktop/backUp/$(ls /etc/login.defs)
cat /etc/pam.d/system-login > /home/user/Desktop/backUp/$(ls /etc/pam.d/system-logins)
cat /etc/pam.d/passwd > /home/user/Desktop/backUp/$(ls /etc/pam.d/passwd)
cat /etc/lightdm/lightdm.conf > /home/user/Desktop/backUp/$(ls /etc/lightdm/lightdm.conf)
cat /etc/ssh/sshd_config > /home/user/Desktop/backUp/$(ls /etc/ssh/sshd_config)

echo -e “# This file contains the auditctl rules that are loaded/n # whenever the audit daemon is started via the initscripts./n # The rules are simply the parameters that would be passed/n # to auditctl.\n # First rule - delete all /n -D /n # Increase the buffers to survive stress events. /n # Make this bigger for busy systems/n -b 1024/n -a exit,always -S unlink -S rmdir /n -a exit,always -S stime.*/n -a exit,always -S setrlimit.*/n -w /var/www -p wa /n -w /etc/group -p wa /n -w /etc/passwd -p wa /n -w /etc/shadow -p wa /n -w /etc/sudoers -p wa /n # Disable adding any additional rules - note that adding *new* rules will require a reboot /n -e 2 ” > /etc/audit/audit.rules

rkhunter --update
rkhunter --checkall
freshclam
