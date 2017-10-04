#!/bin/bash
#
# Saves an image. 
BASEDIR=/var/www/cgi-bin
HOSTNAME=$(hostname)
source $BASEDIR/source/functions.sh
cd $BASEDIR
. tmp/globals
SAVEDIR=$SHAREDIR/$HOSTNAME/docker.saves
[[ ! -d $SAVEDIR ]] && mkdir -p $SAVEDIR

#	Save Image
	echo "Starting save of $SAVECONTAINER to $SAVEDIR" >> tmp/joblog
	echo "docker save -o $SAVEDIR/${SAVECONTAINER}.tar $SAVECONTAINER" >> tmp/joblog
	docker save -o "$SAVEDIR/${SAVECONTAINER}.tar" $SAVECONTAINER 2>&1 >> tmp/joblog
	if [[ -f $SAVEDIR/${SAVECONTAINER}.tar ]]
	then
		echo "$SAVECONTAINER saved." >> tmp/joblog
		JOBSTATUS="complete"
	else
		echo "It all went wrong.  Not saved." >> tmp/joblog
		JOBSTATUS="warn"
	fi
	echo "SCRIPT END"
	write_global JOBSTATUS
	delete_global SAVECONTAINER

