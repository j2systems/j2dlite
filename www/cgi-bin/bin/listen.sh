#!/bin/bash
#
ROOTPATH=/var/www/cgi-bin
TRIGGER=${ROOTPATH}/tmp/trigger
SCRIPTPATH=${ROOTPATH}/bin
source ${ROOTPATH}/source/functions.sh
while : 
do
	while :
	do
		unset COMMAND
		while [[ ! -f ${TRIGGER} ]]
		do
			sleep 1
		done
		DOTHIS=$(cat $TRIGGER)
		bash ${SCRIPTPATH}/${DOTHIS}
		log "${DOTHIS}"
		rm -f ${TRIGGER}
	done
done

