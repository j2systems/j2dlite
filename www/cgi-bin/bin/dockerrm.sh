#!/bin/bash
#
# Removes an image 

BASEDIR=/var/www/cgi-bin
HOSTNAME=$(hostname)
source $BASEDIR/source/functions.sh
cd $BASEDIR
. tmp/globals
#	Remove
	echo "docker rm $RMCONTAINER" >> tmp/joblog
	docker rm $RMCONTAINER 2>&1 >> tmp/joblog
	##[[ -f $BASEDIR/tmp/nginx ]] && sed -i "/^$RMCONTAINER /d" $BASEDIR/tmp/nginx
	$BASEDIR/bin/mclientupdate.sh
	docker volume prune -f
	JOBSTATUS="complete"
	write_global JOBSTATUS
	delete_global RMCONTAINER
	. ${BASEDIR}/bin/zfs-status.sh
