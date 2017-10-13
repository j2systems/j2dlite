#!/bin/bash
#
# Loads an image

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

LOADPATH=$(echo $1|cut -d "," -f2)
LOADDFILE=$(echo $1|cut -d "," -f3)

#	Load
	echo "Starting load of ${LOADFILE}"
	echo "docker load -i ${LOADPATH}/${LOADFILE}
	docker load -i ${LOADPATH}/${LOADFILE} 2>&1
	echo "SCRIPT END"

