#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
THISIFS=$IFS
IFS=","
if [[ "$1" == "" ]]
then
	while read BUTTONNAME STYLE
	do
		echo "ADVMENU,,${BUTTONNAME},${STYLE}"
	done < ${CONFIGPATH}/advbuttons
else
	
	echo "SUBMENU,RELOAD"
	while read BUTTONNAME "STYLE"
	do
		echo "SUBMENU,$1,${BUTTONNAME},${STYLE}"
	done < ${CONFIGPATH}/$1_buttons
	echo "SUBMENU,END,,"
fi
IFS=${THISIFS}
