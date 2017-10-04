#!/bin/bash
#
# Removes an image 

. /var/www/cgi-bin/tmp/globals
source ${SOURCEDIR}/functions.sh
cd $BASEDIR
. tmp/globals
#	Remove
	log "docker rm ${RMCONTAINER}" 
	docker rm ${RMCONTAINER} 2>&1
	${BINDIR}/mclientupdate.sh
	${BINDIR}/docker-volprune.sh 
	JOBSTATUS="complete"
	write_global JOBSTATUS
	delete_global RMCONTAINER
