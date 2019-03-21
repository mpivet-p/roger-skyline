#!/bin/bash

# ROOT CHECKING
if [ "$EUID" -ne 0 ]
then
	echo -e "\e[31;1mPlease run as root\e[0m"
	exit 1
fi

# ARGS CHECKING
	read -p "Would you like a full install ? [y/n] : " WEB

# SERVER SETUP

	read -p "Please enter username : " NAME
	apt-get update
	apt-get upgrade


if [ $WEB == "Y" ] || [ $WEB == "y" ]
then
	# PACKAGE DOWNLOADING
	apt-get install sudo
	apt-get install vim
	apt-get install git
	apt-get install openssh-server
	apt-get install net-tools
	apt-get install iptables
	apt-get install mailutils
	apt-get install sendmail-bin
	apt-get install sendmail
	apt-get install fail2ban

	# CONFIG
	git clone "https://github.com/mpivet-p/server_conf.git" /home/$NAME/.server_conf;
	read -p "Please choose a port for SSH Service : " PORT;
	sed -i "13s/.*/Port $PORT/g" /home/$NAME/.server_conf/sshd_config
	cp /home/$NAME/.server_conf/sshd_config /etc/ssh/sshd_config
	#cp /home/$NAME/.server_conf/firewall /etc/init.d/firewall
	cp /home/$NAME/.server_conf/.update.bash /home/$NAME/.update.bash
	cp /home/$NAME/.server_conf/.cron_watch.bash /home/$NAME/.cron_watch.bash
	cp /home/$NAME/.server_conf/interfaces /etc/network/interfaces
	#chmod +x /etc/init.d/firewall
	#/etc/init.d/firewall
	#update-rc.d defaults firewall
	echo "0 4 * * sun root bash /home/$NAME/.update.bash >> /var/log/update_script.log" >> /etc/crontab
	echo "@reboot root bash /home/$NAME/.update.bash >> /var/log/update_script.log" >> /etc/crontab
	echo "0 0 * * * root bash /home/$NAME/.cron_watch.bash" >> /etc/crontab
	echo -e "$NAME\tALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
	mkdir /home/$NAME/.ssh
	cp /home/$NAME/.server_conf/authorized_keys /home/$NAME/.ssh/authorized_keys
	GATEWAY=$(route -n | sed -n '3p' | awk '{print $2}')
	read -p "Please Choose an IP Address : " ADDRESS
	echo -e "auto enp0s3\niface enp0s3 inet static\n\taddress $ADDRESS\n\tnetmask 255.255.255.252\n\tgateway $GATEWAY" >> /etc/network/interfaces
	REF_SUM=$(md5sum /etc/crontab)
	sed -i '4s|.*|REF_SUM="AAA"|' /home/$NAME/.server_conf/.cron_watch.bash
	sed -i "4s|AAA|$REF_SUM|" /home/$NAME/.server_conf/.cron_watch.bash
fi
apt-get install apache2
