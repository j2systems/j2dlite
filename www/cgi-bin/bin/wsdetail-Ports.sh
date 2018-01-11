#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
# Reset PORTS Global, add DEFAULTPORTS and wsdetail_Ports
delete_global PORTS
PORTS=${DEFAULTPORTS}
for PORT in $(echo ${DEFAULTPORTS})
do
	append_global PORTS ${PORT}
done
while read PORT
do
	append_global PORTS ${PORT}
done < ${SYSTEMPATH}/wsdetail_Ports
. ${BINPATH}/config.sh
echo "DETAIL,Ports,REFRESH,Port,Remove:Add"
echo "DETAIL,Ports,FIELDS,INPUT,BUTTON"
echo "DETAIL,Ports,STYLES,gray,red:green"

COUNT=1
while read PORT
do
	echo "DETAIL,Ports,${COUNT},${PORT}"
	COUNT=$((++COUNT))
done < ${SYSTEMPATH}/wsdetail_Ports
echo "DETAIL,Ports,${COUNT},"

