#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
[[ ! -f ${SYSTEMPATH}/wsdetail_IPAlias ]] && touch ${SYSTEMPATH}/wsdetail_IPAlias
echo "DETAIL,IPAlias,REFRESH,URL,Port,Destination,Des Port,Remove:Add"
echo "DETAIL,IPAlias,FIELDS,INPUT,INPUT,SELECT,SELECT,BUTTON"
echo "DETAIL,IPAlias,STYLES,gray,gray,gray,gray,red:green"

COUNT=1
while read URL PORT DESTINATION DPORT
do
	echo "DETAIL,IPAlias,${COUNT},${URL},${PORT},${DESTINATION}:server1 server2 server3,${DPORT}:${PORTS}"
	COUNT=$((++COUNT))
done < ${SYSTEMPATH}/wsdetail_IPAlias
echo "DETAIL,IPAlias,${COUNT},,,:server1 server2 server3,:${PORTS}"
