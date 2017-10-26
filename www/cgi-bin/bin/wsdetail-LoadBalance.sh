#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

[[ ! -f ${SYSTEMPATH}/wsdetail_LoadBalance ]] && touch ${SYSTEMPATH}/wsdetail_LoadBalance

echo "DETAIL,LoadBalance,REFRESH,URL,Port,LBName,LBAlgorithm,Destination,DestPort,Remove:Add"
echo "DETAIL,LoadBalance,FIELDS,INPUT,INPUT,INPUT,SELECT,SELECT,SELECT,BUTTON"
echo "DETAIL,LoadBalance,STYLES,gray,gray,gray,gray,gray,gray,red:green"
THISIFS=$IFS
IFS=","
COUNT=1
while read URL PORT LBNAME LBALGO DESTINATION DPORT
do
	if [[ ${COUNT} -eq 2 ]]
	then
		echo "DETAIL,LoadBalance,FIELDS,TD,TD,TD,SELECT,SELECT,SELECT,BUTTON"
	fi
	echo "DETAIL,LoadBalance,${COUNT},${URL},${PORT},${LBNAME},${LBALGO}:1 2,{DESTINATION}:server1 server2 server3,${DPORT}:${PORTS}"
	COUNT=$((++COUNT))
done < ${SYSTEMPATH}/wsdetail_LoadBalance
echo "DETAIL,LoadBalance,${COUNT},,,,:1 2,:server1 server2 server3,:${PORTS}"
if [[ ${COUNT} -gt 1 ]] 
then
	echo "DETAIL,LoadBalance,NEW,,,,:1 2,:server1 server2 server3,:${PORTS}"
fi
IFS=$THISIFS
