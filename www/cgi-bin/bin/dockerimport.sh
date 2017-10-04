#!/bin/bash
#
# Imports an image 

BASEDIR=/var/www/cgi-bin
source $BASEDIR/source/functions.sh

cd $BASEDIR
. tmp/globals
#	Import
	# open_terminal
	[[ "$IMPORTNAME" == "" ]] && IMPORTNAME="new"
	echo "Starting import of $IMPORTFILE as $IMPORTNAME"
	echo "docker import $IMPORTPATH/$IMPORTFILE j2docker:$IMPORTNAME"
	docker import $IMPORTPATH/$IMPORTFILE j2docker:$IMPORTNAME 2>&1
	echo "SCRIPT END"
	. ${BASEDIR}/bin/zfs-status.sh
	delete_global TERMTARGET
	delete_global IMPORTFILE
	delete_global IMPORTPATH
	delete_global IMPORTNAME

