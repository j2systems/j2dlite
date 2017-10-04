#!/bin/bash
#
# Exports an images 

BASEDIR=/var/www/cgi-bin
HOSTNAME=$(hostname)
source $BASEDIR/source/functions.sh
cd $BASEDIR
. tmp/globals

#	Commit
	echo "Commiting $COMMITCONTAINER" >> tmp/joblog
	NEWREF=$(docker inspect --format='{{json .Config.Image}}' $COMMITCONTAINER|tr -d "\""|cut -d ":" -f2)
 	echo "docker commit  $COMMITCONTAINER j2systems/docker:${NEWREF}-final" >> tmp/joblog
	docker commit  $COMMITCONTAINER j2systems/docker:${NEWREF}-final
	JOBSTATUS="complete"
	write_global JOBSTATUS
	delete_global COMMITCONTAINER
	. ${BASEDIR}/bin/zfs-status.sh
