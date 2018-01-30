#!/bin/bash
#
# Imports a cache routine 
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

CACHENAMESPACE=$(echo $1|cut -d "," -f1)
CACHEROUTINEDIR=$(echo $1|cut -d "," -f2)
CACHEROUTINEFILE=$(echo $1|cut -d "," -f3)
DEFINSTANCE=$(docker exec ${RTNCONTAINER} ccontrol list|grep "(default)"|cut -d "'" -f2)

	CACHEROUTINEPATH=$(echo ${CACHEROUTINEDIR}|sed "s,${SHAREDIR},/mnt/host,g")
	IMPORTTHIS=$(echo ${CACHEROUTINEPATH}/${CACHEROUTINEFILE}|sed "s,${SHAREDIR},/mnt,g")

#	Import

	echo "Starting import of ${CACHEROUTINEFILE} to ${CACHENAMESPACE} in ${RTNCONTAINER}" 
	echo "docker exec -t ${RTNCONTAINER} bash -c 'echo -e \"_SYSTEM\nj2andUtoo\\nzn \\\"${CACHENAMESPACE}\\\"\\nW \\\$SYSTEM.OBJ.Load(\\\"${IMPORTTHIS}\\\",\\\"ck\\\")\nh\n\"| csession ${DEFINSTANCE}'"
	eval docker exec -t ${RTNCONTAINER} bash -c \'echo -e \"_SYSTEM\\nj2andUtoo\\nzn \\\"${CACHENAMESPACE}\\\"\\nW \\\$SYSTEM.OBJ.Load\(\\\"${IMPORTTHIS}\\\",\\\"ck\\\"\)\\nh\\n\"\| csession ${DEFINSTANCE}\'  2>&1
	echo "SCRIPT END"
	delete_global RTNCONTAINER




