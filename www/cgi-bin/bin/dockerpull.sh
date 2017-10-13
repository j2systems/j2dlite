#!/bin/bash
#
# Pulls an image 

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

PULLIMAGE=$1

#	Pull Image
	# open_terminal
	status "Pulling ${PULLIMAGE}"
	echo "Starting pull of ${PULLIMAGE}"
	echo "docker pull ${PULLIMAGE}"
	docker pull ${PULLIMAGE} 2>&1
	echo "SCRIPT END"

