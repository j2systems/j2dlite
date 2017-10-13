#!/bin/bash
#
# Imports a cache routine 
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

CACHENAMESPACE=$(echo $1|cut -d "," -f1)
CACHEROUTINEDIR=$(echo $1|cut -d "," -f2)
CACHEROUTINEFILE=$(echo $1|cut -d "," -f3)


	CACHEROUTINEPATH=$(echo ${CACHEROUTINEDIR}|sed "s,${SHAREDIR},/mnt/host,g")
	IMPORTTHIS=$(echo ${CACHEROUTINEPATH}/${CACHEROUTINE}|sed "s,${SHAREDIR},/mnt,g")

#	Import

	echo "Starting import of ${CACHEROUTINEFILE} to ${CACHENAMESPACE} in ${RTNCONTAINER}" 
	echo "docker exec -t ${RTNCONTAINER} bash -c 'echo -e \"_SYSTEM\nj2andUtoo\\nzn \\\"${CACHENAMESPACE}\\\"\\nW \\\$SYSTEM.OBJ.Load(\\\"${IMPORTTHIS}\\\",\\\"ck\\\")\nh\n\"| csession hs'"
	eval docker exec -t ${RTNCONTAINER} bash -c \'echo -e \"_SYSTEM\\nj2andUtoo\\nzn \\\"${CACHENAMESPACE}\\\"\\nW \\\$SYSTEM.OBJ.Load\(\\\"${IMPORTTHIS}\\\",\\\"ck\\\"\)\\nh\\n\"\| csession hs\'  2>&1
	echo "SCRIPT END"
	delete_global RTNCONTAINER




