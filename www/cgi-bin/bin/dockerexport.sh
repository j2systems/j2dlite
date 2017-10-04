#!/bin/bash
#
# Exports an images 

BASEDIR=/var/www/cgi-bin
HOSTNAME=$(hostname)
source $BASEDIR/source/functions.sh
cd $BASEDIR
. tmp/globals
EXPORTDIR=$SHAREDIR/$HOSTNAME/docker.exports
[[ ! -d $EXPORTDIR ]] && mkdir -p $EXPORTDIR
#	Export
	echo "Starting export of $EXPORTCONTAINER to $EXPORTDIR" >> tmp/joblog 
	echo "docker export -o $EXPORTDIR/${EXPORTCONTAINER}.tar" >> tmp/joblog
	docker export -o "$EXPORTDIR/${EXPORTCONTAINER}.tar" $EXPORTCONTAINER
	if [[ -f $EXPORTDIR/${EXPORTCONTAINER}.tar ]]
	then
		echo "$EXPORTCONTAINER exported." >> tmp/joblog
		JOBSTATUS="complete"
	else
		echo "It all went wrong.  Not exported." >> tmp/joblog
		JOBSTATUS="warn"
	fi
	write_global JOBSTATUS
	delete_global EXPORTCONTAINER

