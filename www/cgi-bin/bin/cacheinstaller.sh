#!/bin/bash
#
# Runs an installer in healthshare image 

BASEDIR=/var/www/cgi-bin
source $BASEDIR/source/functions.sh
cd $BASEDIR
. tmp/globals
#	Copy installer to tmp, chmodd to 777, run installer
	echo "docker cp $INSTALLERPATH/$INSTALLER $INSTALLCONTAINER:/tmp/${INSTALLER}.sh"
	docker cp $INSTALLERPATH/$INSTALLER $INSTALLCONTAINER:/tmp/${INSTALLER}.sh
	docker exec -t $INSTALLCONTAINER chmod 777 /tmp/${INSTALLER}.sh
	docker exec -t $INSTALLCONTAINER /bin/sh -c "/tmp/${INSTALLER}.sh"
	JOBSTATUS="complete"
	#write_global JOBSTATUS
	delete_global RTNCONTAINER
	#delete_global INSTALLERPATH
	#delete_global INSTALLER
	#delete_global INSTALLCONTAINER
	echo "SCRIPT END"


