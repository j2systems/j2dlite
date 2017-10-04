#!/bin/bash
#
# Builds an images 

BASEDIR=/var/www/cgi-bin
TEMPLATEDIR=$BASEDIR/source/build
BUILDDIR=$BASEDIR/build
source $BASEDIR/source/functions.sh
cd $BASEDIR
. tmp/globals
#	Load
	echo "Starting load of $LOADFILE"
	echo "docker load -i $LOADPATH/$LOADFILE
	docker load -i $LOADPATH/$LOADFILE 2>&1
	echo "SCRIPT END"
        status "Ready"
	delete_global TERMTARGET
	delete_global LOADFILE
	delete_global LOADPATH


