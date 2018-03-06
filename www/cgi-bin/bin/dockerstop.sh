#!/bin/bash
#
# Stops a container 

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

#	Stop
	delete_global JOBSTATUS
 	log "docker stop ${STOPCONTAINER}" 
	if [[ "$(isHS ${STOPCONTAINER})" == "true" ]]
	then
		# purge and move journals
		docker exec ${STOPCONTAINER} /bin/sh /sbin/manage_journals.sh 2>&1 
	fi
	docker stop ${STOPCONTAINER} 2>&1 
	bash ${BINPATH}/mclientupdate.sh
#	bash ${BINPATH}/docker-volprune.sh
	JOBSTATUS="complete"
	write_global JOBSTATUS
	delete_global STOPCONTAINER

