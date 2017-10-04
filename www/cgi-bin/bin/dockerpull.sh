#!/bin/bash
#
# Pulls an image 

BASEDIR=/var/www/cgi-bin
TEMPLATEDIR=$BASEDIR/source/build
BUILDDIR=$BASEDIR/build
source $BASEDIR/source/functions.sh
cd $BASEDIR
. tmp/globals
#	Pull Image
	# open_terminal
	status "Pulling $PULLIMAGE"
	echo "Starting pull of $PULLIMAGE"
	echo "docker pull $PULLIMAGE"
	docker pull $PULLIMAGE 2>&1
	echo "SCRIPT END"
	delete_global TERMTARGET
	delete_global PULLIMAGE
	echo "SCRIPT END"
	status "ready"
	. ${BASEDIR}/bin/zfs-status.sh
