#!/bin/bash
#
# Stops a container 

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

#	Stop
	delete_global JOBSTATUS
 	log "docker stop ${STOPCONTAINER}" 
	docker stop ${STOPCONTAINER} 2>&1 
	bash ${BINPATH}/mclientupdate.sh
	JOBSTATUS="complete"
	write_global JOBSTATUS
	delete_global STOPCONTAINER

