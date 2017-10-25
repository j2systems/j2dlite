#!/bin/bash
#
# Creates table from zfs list

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
echo "DISKVOL,RELOAD,Filesystem,Type,Size,Used,Available,Capacity,Mount Point"
COUNT=0
while read FILESYSTEM TYPE SIZE USED AVAILABLE CAPACITY MOUNT
do
	COUNT=$((++COUNT))
	echo "DISKVOL,${COUNT},${FILESYSTEM},${TYPE},${SIZE},${USED},${AVAILABLE},${CAPACITY},${MOUNT}"
done < <(df -hTP|grep -v "/tmp/tcloop"|grep -v "Mounted on")
