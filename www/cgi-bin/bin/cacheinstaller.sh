#!/bin/bash
#
# Runs an installer in healthshare image

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

INSTALLCONTAINER=$(echo $1|cut -d "," -f1)
INSTALLPATH=$(echo $1|cut -d "," -f2)
INSTALLFILE=$(echo $1|cut -d "," -f3)

#	Copy installer to tmp, chmod to 777, run installer
	echo "docker cp ${INSTALLPATH}/${INSTALLfile} ${INSTALLCONTAINER}:/tmp/${INSTALLFILE}.sh"
	docker cp ${INSTALLPATH}/${INSTALLFILE} ${INSTALLCONTAINER}:/tmp/${INSTALLFILE}.sh
	docker exec -t ${INSTALLCONTAINER} chmod 777 /tmp/${INSTALLFILE}.sh
	docker exec -t ${INSTALLCONTAINER} /bin/sh -c "/tmp/${INSTALLFILE}.sh"
	echo "SCRIPT END"

