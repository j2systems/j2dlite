#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

[[ ! -f ${SYSTEMPATH}/wsdetail_LoadBalance ]] && touch ${SYSTEMPATH}/wsdetail_LoadBalance

echo "DETAIL,LoadBalance,REFRESH,URL,Port,Destination,Des Port,Remove:Add"
echo "DETAIL,LoadBalance,FIELDS,INPUT,INPUT,SELECT,SELECT,BUTTON"
echo "DETAIL,LoadBalance,STYLES,gray,gray,gray,gray,red:green"

COUNT=1
while read URL PORT DESTINATION DPORT
do
	echo "DETAIL,LoadBalance,${COUNT},${URL},${PORT},${DESTINATION}:server1 server2 server3,${DPORT}:${PORTS}"
	COUNT=$((++COUNT))
done < ${SYSTEMPATH}/wsdetail_LoadBalance
echo "DETAIL,LoadBalance,${COUNT},,,:server1 server2 server3,:${PORTS}"
