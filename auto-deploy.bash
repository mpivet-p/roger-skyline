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
	clear
	echo -e "\e[34;1m** STARTING WEBSITE DEPLOYMENT **\e[0m"
	sleep 1
	# PACKAGE DOWNLOADING
	apt-get install sudo -y
	apt-get install vim -y
	apt-get install git -y
	apt-get install openssh-server -y
	apt-get install net-tools -y
	apt-get install iptables -y
	apt-get install mailutils -y
	apt-get install sendmail-bin -y
	apt-get install sendmail -y
	apt-get install fail2ban -y
	apt-get install portsentry -y

	# CONFIG
	git clone "https://github.com/mpivet-p/server_conf.git" /home/$NAME/.server_conf;

	# SSH SETUP
	read -p "Please choose a port for SSH Service : " PORT;
	sed -i "13s/.*/Port $PORT/g" /home/$NAME/.server_conf/sshd_config
	cp /home/$NAME/.server_conf/sshd_config /etc/ssh/sshd_config
	mkdir /home/$NAME/.ssh
	cp /home/$NAME/.server_conf/authorized_keys /home/$NAME/.ssh/authorized_keys
	service ssh restart
	service sshd restart

	# CRON SETUP
	cp /home/$NAME/.server_conf/.update.bash /home/$NAME/.update.bash
	cp /home/$NAME/.server_conf/.cron_watch.bash /home/$NAME/.cron_watch.bash
	echo -e "00 4\t* * sun\troot\tbash /home/$NAME/.update.bash >> /var/log/update_script.log" >> /etc/crontab
	echo -e "@reboot\troot\tbash /home/$NAME/.update.bash >> /var/log/update_script.log" >> /etc/crontab
	echo -e "00 0\t* * *\troot\tbash /home/$NAME/.cron_watch.bash" >> /etc/crontab
	REF_SUM=$(md5sum /etc/crontab)
	sed -i '4s|.*|REF_SUM="AAA"|' /home/$NAME/.server_conf/.cron_watch.bash
	sed -i "4s|AAA|$REF_SUM|" /home/$NAME/.server_conf/.cron_watch.bash
	service cron restart

	# SUDO SETUP
	echo -e "$NAME\tALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
	service sudo restart

	# NETWORK INTERFACES SETUP
	cp /home/$NAME/.server_conf/interfaces /etc/network/interfaces
	GATEWAY=$(route -n | sed -n '3p' | awk '{print $2}')
	read -p "Please Choose an IP Address : " ADDRESS
	echo -e "auto enp0s3\niface enp0s3 inet static\n\taddress $ADDRESS\n\tnetmask 255.255.255.252\n\tgateway $GATEWAY" >> /etc/network/interfaces
	service networking restart

	# MAIL PATCH
	sed -i '4s|root:.*|root: root|' /etc/aliases

	# FIREWALL
	sed -i "s/PORT/$PORT/" /home/$NAME/.server_conf/firewall
	mv /home/$NAME/.server_conf/firewall /etc/init.d/firewall
	chmod +x /etc/init.d/firewall
	/etc/init.d/firewall
	update-rc.d firewall defaults

	# PORTSENTRY CONFIG
	sed -i 's/tcp/atcp/' /etc/default/portsentry
	sed -i 's/udp/audp/' /etc/default/portsentry
	sed -i 's/BLOCK_UDP="0"/BLOCK_UDP="1"/' /etc/portsentry/portsentry.conf
	sed -i 's/BLOCK_TCP="0"/BLOCK_TCP="1"/' /etc/portsentry/portsentry.conf
	service portsentry restart
	echo -e "\e[32;1m** SERVER CONFIG DONE **\e[0m"
	sleep 1
	clear
fi

# BEGINNING WEBSITE DEPLOY
echo -e "\e[34;1m** STARTING WEBSITE DEPLOYMENT **\e[0m"
sleep 2
apt-get install apache2 -y
apt-get install libapache2-mod-php7.0 -y
git clone https://github.com/mpivet-p/RS_WEB.git /var/www/html/www.myroger.fr
rm -rf /etc/apache2/sites-available/*
rm -rf /etc/apache2/sites-enabled/*
mv /var/www/html/www.myroger.fr/00-www.myroger.fr.conf /etc/apache2/sites-available/00-www.myroger.fr.conf
bash /home/$NAME/.server_conf/get_ssl_key.bash
a2ensite 00-www.myroger.fr
a2enmod ssl
service apache2 restart
echo -e "\e[32;1m** WEBSITE DEPLOYMENT DONE **\n\e[0m"
