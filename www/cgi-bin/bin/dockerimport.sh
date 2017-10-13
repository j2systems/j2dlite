#!/bin/bash
#
# Imports an image 
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

IMPORTNAME=$(echo $1|cut -d "," -f1)
IMPORTPATH=$(echo $1|cut -d "," -f2)
IMPORTFILE=$(echo $1|cut -d "," -f3)

#	Import
	[[ "${IMPORTNAME}" == "" ]] && {IMPORTNAME}="new"
	echo "Starting import of ${IMPORTFILE} as ${IMPORTNAME}"
	echo "docker import ${IMPORTPATH}/${IMPORTFILE} j2docker:${IMPORTNAME}"
	docker import ${IMPORTPATH}/${IMPORTFILE} j2docker:${IMPORTNAME} 2>&1
	echo "SCRIPT END"

