#!/bin/bash
#
# Imports a cache routine 

BASEDIR=/var/www/cgi-bin
HOSTNAME=$(hostname)
source $BASEDIR/source/functions.sh
cd $BASEDIR
. tmp/globals

	CACHEROUTINEPATH=$(echo $CACHEROUTINEDIR|sed "s,$SHAREDIR,/mnt/host,g")
	IMPORTTHIS=$(echo $CACHEROUTINEPATH/$CACHEROUTINE|sed "s,$SHAREDIR,/mnt,g")

#	Import

	echo "Starting import of $CACHEROUTINE to $NAMESPACE in $RTNCONTAINER" 
	echo "docker exec -t ${RTNCONTAINER} bash -c 'echo -e \"_SYSTEM\nj2andUtoo\\nzn \\\"${NAMESPACE}\\\"\\nW \\\$SYSTEM.OBJ.Load(\\\"${IMPORTTHIS}\\\",\\\"ck\\\")\nh\n\"| csession hs'" >> tmp/joblog
	eval docker exec -t ${RTNCONTAINER} bash -c \'echo -e \"_SYSTEM\\nj2andUtoo\\nzn \\\"${NAMESPACE}\\\"\\nW \\\$SYSTEM.OBJ.Load\(\\\"${IMPORTTHIS}\\\",\\\"ck\\\"\)\\nh\\n\"\| csession hs\'  2>&1 |tee tmp/cacheroutineimport
	echo "SCRIPT END"
	#delete_global RTNCONTAINER
	#delete_global NAMESPACE
	#delete_global CACHEROUTINE
	#delete_global CACHEROUTINEDIR

