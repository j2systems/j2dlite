#!/bin/bash
#
# Builds an images 

BASEDIR=/var/www/cgi-bin
source $BASEDIR/source/functions.sh
cd $BASEDIR
. tmp/globals
#	Remove Image
#§	# open_terminal
	REMOVE=$(echo $RMIIMAGE|sed "s,_FSLASH_,/,g"|sed "s,_COLON_,:,g")
	[[ $(echo $REMOVE|grep -c -e ":$") -ne 0 ]] && REMOVE=$(echo $REMOVE|tr -d ":")
	echo "Delete $REMOVE:"
	echo "docker rmi $REMOVE"
	docker rmi $REMOVE 2>&1
	docker volume prune -f
	echo "SCRIPT END"
	delete_global TERMTARGET
	delete_global RMIIMAGE
	status "Ready"
	rm -rf ${BASEDIR}/tmp/nag
	. ${BASEDIR}/bin/zfs-status.sh
