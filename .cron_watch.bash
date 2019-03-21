#!bin/bash

ROOT_MAIL="root@localhost"
REF_SUM="8f111d100ea459f68d333d63a8ef2205  /etc/crontab"
MD5SUM=$(sudo md5sum /etc/crontab)


if [ "${REF_SUM}" != "${MD5SUM}" ];
	then
	CONTENT="Alert ! crontab has been modified !!"
	CC="crontab Modified !"
	echo "${CONTENT}" | mail -s "${CC}" "${ROOT_MAIL}"
fi
