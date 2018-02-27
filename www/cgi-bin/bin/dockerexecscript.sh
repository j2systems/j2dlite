#!/bin/bash
#
# Run a script

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

	docker cp ${INSTALLERPATH}/${INSTALLER} ${SCRIPTCONTAINER}:/tmp
	docker exec ${SCRIPTCONTAINER} chmod 777 /tmp/${INSTALLER}
	docker exec ${SCRIPTCONTAINER} /bin/sh /tmp/${INSTALLER}
	echo "SCRIPT END"
	delete_global SCRIPTCONTAINER
	delete_global INSTALLER
	delete_global INSTALLERPATH	
