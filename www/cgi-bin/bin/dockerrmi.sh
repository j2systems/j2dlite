#!/bin/bash
#
# Builds an images 

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

RMIIMAGE=$1

#	Remove Image

	REMOVE=$(echo ${RMIIMAGE}|sed "s,_FSLASH_,/,g"|sed "s,_COLON_,:,g")
	[[ $(echo ${REMOVE}|grep -c -e ":$") -ne 0 ]] && REMOVE=$(echo ${REMOVE}|tr -d ":")
	echo "Delete ${REMOVE}:"
	echo "docker rmi ${REMOVE}"
	docker rmi ${REMOVE} 2>&1
	echo "SCRIPT END"

