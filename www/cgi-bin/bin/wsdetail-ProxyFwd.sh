#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

[[ ! -f ${SYSTEMPATH}/wsdetail_ProxyFwd ]] && touch ${SYSTEMPATH}/wsdetail_ProxyFwd
echo "DETAIL,ProxyFwd,REFRESH,URL,Port,Destination,DestPort,Remove:Add"
echo "DETAIL,ProxyFwd,FIELDS,INPUT,INPUT,SELECT,SELECT,BUTTON"
echo "DETAIL,ProxyFwd,STYLES,gray,gray,gray,gray,red:green"
THISIFS=$IFS
IFS=","
COUNT=1
while read URL PORT DESTINATION DPORT
do
	echo "DETAIL,ProxyFwd,${COUNT},${URL},${PORT},${DESTINATION}:server1 server2 server3,${DPORT}:${PORTS}"
	COUNT=$((++COUNT))
done < ${SYSTEMPATH}/wsdetail_ProxyFwd
echo "DETAIL,ProxyFwd,${COUNT},,,:server1 server2 server3,:${PORTS}"
IFS=$THISIFS
