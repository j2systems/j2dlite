#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

echo "DETAIL,Ports,REFRESH,Port,Delete:Add"
echo "DETAIL,Ports,FIELDS,INPUT,BUTTON"
echo "DETAIL,Ports,STYLES,gray,red:green"

COUNT=1
for PORT in ${PORTS}
do
	echo "DETAIL,Ports,${COUNT},${PORT}"
	COUNT=$((++COUNT))
done
echo "DETAIL,Ports,,"

