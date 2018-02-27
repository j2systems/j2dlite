#!/bin/bash
#
# Run a script

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
	INSTALLERPATH=$(echo ${INSTALLERPATH}|sed "s,/mnt/shared,/mnt/host,g")
	echo "Copying ${INSTALLERPATH}/${INSTALLER} to /tmp"
	docker exec ${SCRIPTCONTAINER} cp ${INSTALLERPATH}/${INSTALLER} /tmp
	echo "Making script executable"
	docker exec ${SCRIPTCONTAINER} chmod 777 /tmp/${INSTALLER}
	echo "Running script..."
	docker exec ${SCRIPTCONTAINER} /bin/sh /tmp/${INSTALLER} 2>&1
	echo "SCRIPT END"
	delete_global SCRIPTCONTAINER
	delete_global INSTALLER
	delete_global INSTALLERPATH	
