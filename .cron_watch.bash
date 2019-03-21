#!/bin/bash

ROOT_MAIL="root@localhost"
REF_SUM="c3642dd14cc14012cbb9cb7d8664b72c  /etc/crontab"
MD5SUM=$(md5sum /etc/crontab)

if [ "${REF_SUM}" != "${MD5SUM}" ];
	then
	CONTENT="Alert ! crontab has been modified !!"
	CC="crontab Modified !"
	echo "${CONTENT}" | mail -s "${CC}" "${ROOT_MAIL}"
fi
