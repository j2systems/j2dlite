#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

if [[ "$1" == "" ]] 
then
	INFOHEADER=CONTAINERINFO
	echo "CONTAINERINFO,CONTAINER-INFO-REFRESH"
else
	INFOHEADER=CONTAINERDETAIL
fi
while read NAME IMAGE STATUS
do
	ISHS=$(isHS ${NAME})
	if [[ $(echo $STATUS|grep -c -e "^Up") -eq 1 ]] 
	then
		CONTAINERDETAIL=$(get_container_ip ${NAME})
	else
		CONTAINERDETAIL="offline"
	fi		
	echo "${INFOHEADER},${NAME},${IMAGE},${CONTAINERDETAIL},${ISHS}"
done < <(docker ps -a --format "{{.Names}} ({{.Image}}) {{.Status}}"|grep "$1")
[[ "${ISHS}" == "" ]] && echo "CONTAINERINFO,NOCONTAINERS"
