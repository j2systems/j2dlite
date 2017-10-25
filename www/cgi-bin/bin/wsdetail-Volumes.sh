#!/bin/bash
#
# Creates table from zfs list

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

echo "DETAIL,Volumes,REFRESH,Filesystem,Type,Size,Used,Available,Capacity,Mount Point"
echo "DETAIL,Volumes,FIELDS,TD,TD,TD,TD,TD,TD,TD"
echo "DETAIL,Volumes,STYLES,white,white,white,white,white,white,white"
COUNT=0
while read FILESYSTEM TYPE SIZE USED AVAILABLE CAPACITY MOUNT
do
	COUNT=$((++COUNT))
	echo "DETAIL,Volumes,${COUNT},${FILESYSTEM},${TYPE},${SIZE},${USED},${AVAILABLE},${CAPACITY},${MOUNT}"
done < <(df -hTP|grep -v "/tmp/tcloop"|grep -v "Mounted on")
