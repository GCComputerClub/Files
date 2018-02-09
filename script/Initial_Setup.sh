#!/bin/bash
#AUTHOR: HECHEN HU



#USE THREE EMPTY LINES FOR SEPARATING EACH SECTION; MAKE SURE TO ADD COMMENTS
#All back up files will be put in /backUp and named with their original directory
#All script related files will be put in /script
#All recorded system information will be put in /sysInfo
#Run the script with the absolute path of Desktop as the argument



#Desktop directory
Desktop=$1



#Record all packages installed, all services active
mkdir "$Desktop"/sysInfo
apt list --installed > "$Desktop"/sysInfo/appList.txt
service --status-all > "$Desktop"/sysInfo/service.txt



#Check if there are any kali tools installed
echo "Checking Kali Tool's presence"
grep -Ff "$Desktop"/script/Kali_Tools_List.txt "$Desktop"/sysInfo/appList.txt > "$Desktop"/sysInfo/Kali_Matched.txt
echo "Task Finish"



#Chekc for media files
locate <$("$Desktop"/script/Video_Files_Format.txt) > "$Desktop"/sysInfo/Video_Matched.txt
locate <$("$Desktop"/script/Audio_Files_Format.txt) > "$Desktop"/sysInfo/Audio_Matched.txt



#General updates and install programs on the checklist
apt-get --assume-yes install gufw auditd audispd-plugins bum fail2ban libpam-cracklib rkhunter clamav clamtk openssl clamav-daemon apparmor apparmor-utils
apt-get --assume-yes install syslogd
apt-get update
apt-get upgrade
apt-get dist-upgrade
apt-get autoclean
apt-get autoremove



#Set log level to "low" for ufw
sudo sed -i '/^LOGLEVEL/s/=.*/=low/' /etc/ufw/ufw.conf



#Check and fix dependencies
apt-get check
apt-get --assume-yes -f install



#General scan
aa-enforce /etc/apparmor.d/usr.bin.firefox
rkhunter --update
rkhunter --checkall
freshclam



#Network enforcement and firewall configuration
sysctl -n net.ipv4.tcp_syncookies
ufw default deny
ufw limit 514/udp

ufw allow ssh
ufw limit ssh/tcp
ufw deny ftp



#Backup all configuration files for 
mkdir "$Desktop"/backUp
cat /etc/sysctl.conf > "$Desktop"/backUp/$(ls /etc/sysctl.conf)
cat /etc/login.defs > "$Desktop"/backUp/$(ls /etc/login.defs)
cat /etc/pam.d/system-login > "$Desktop"/backUp/$(ls /etc/pam.d/system-logins)
cat /etc/pam.d/passwd > "$Desktop"/backUp/$(ls /etc/pam.d/passwd)
cat /etc/lightdm/lightdm.conf > "$Desktop"/backUp/$(ls /etc/lightdm/lightdm.conf)
cat /etc/ssh/sshd_config > "$Desktop"/backUp/$(ls /etc/ssh/sshd_config)



#Start Audit and add Audit rules
auditctl -e 1
cat "$Desktop"/script/Audit_Rules.txt > /etc/audit/audit.rules



#Add syslog configuration file and change permissions of log files
cat "$Desktop"/script/Syslog_conf.txt > /etc/syslog.conf
chmod 0640 /var/log/messages
chmod 0640 /var/log/daemon.log
chmod 0640 /var/log/cron.log
chmod 0600 /var/log/auth.log
chmod 0600 /var/log/critical.log



#Collect all log files for further analysis
mkdir "$Desktop"/sysInfo/logFiles
cp --recursive /var/log "$Desktop"/sysInfo/logFiles



#Check for ShellShock
env x='() { :;}; echo vulnerable' bash -c "echo this is a test"



#Display a cool banner; Operation launch!
cat << "EOF"
  _________________ _________                               __                 _________ .__       ___.                                    
 /  _____/\_   ___ \\_   ___ \  ____   _____ ______  __ ___/  |_  ___________  \_   ___ \|  |  __ _\_ |__                                  
/   \  ___/    \  \//    \  \/ /  _ \ /     \\____ \|  |  \   __\/ __ \_  __ \ /    \  \/|  | |  |  \ __ \                                 
\    \_\  \     \___\     \___(  <_> )  Y Y  \  |_> >  |  /|  | \  ___/|  | \/ \     \___|  |_|  |  / \_\ \                                
 \______  /\______  /\______  /\____/|__|_|  /   __/|____/ |__|  \___  >__|     \______  /____/____/|___  /                                
        \/        \/        \/             \/|__|                    \/                \/               \/                                 
________                              __  .__                _________        ___.                              __         .__        __   
\_____  \ ______   ________________ _/  |_|__| ____   ____   \_   ___ \___.__.\_ |__   ______________________ _/  |________|__| _____/  |_ 
 /   |   \\____ \_/ __ \_  __ \__  \\   __\  |/  _ \ /    \  /    \  \<   |  | | __ \_/ __ \_  __ \____ \__  \\   __\_  __ \  |/  _ \   __\
/    |    \  |_> >  ___/|  | \// __ \|  | |  (  <_> )   |  \ \     \___\___  | | \_\ \  ___/|  | \/  |_> > __ \|  |  |  | \/  (  <_> )  |  
\_______  /   __/ \___  >__|  (____  /__| |__|\____/|___|  /  \______  / ____| |___  /\___  >__|  |   __(____  /__|  |__|  |__|\____/|__|  
        \/|__|        \/           \/                    \/          \/\/          \/     \/      |__|       \/                            
                                   .____                               .__      ._.                                                        
                                   |    |   _____   __ __  ____   ____ |  |__   | |                                                        
                                   |    |   \__  \ |  |  \/    \_/ ___\|  |  \  | |                                                        
                                   |    |___ / __ \|  |  /   |  \  \___|   Y  \  \|                                                        
                                   |_______ (____  /____/|___|  /\___  >___|  /  __                                                        
                                           \/    \/           \/     \/     \/   \/     
EOF
