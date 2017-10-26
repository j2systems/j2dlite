#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

[[ ! -f ${SYSTEMPATH}/wsdetail_LoadBalance ]] && touch ${SYSTEMPATH}/wsdetail_LoadBalance

echo "DETAIL,LoadBalance,REFRESH,URL,Port,LBName,LBAlgorithm,Destination,DestPort,Remove,Add,New"
echo "DETAIL,LoadBalance,FIELDS,INPUT,INPUT,INPUT,SELECT,SELECT,SELECT,BUTTON,BUTTON,BUTTON"
echo "DETAIL,LoadBalance,STYLES,gray,gray,gray,gray,gray,gray,red,green,yellow"
echo "DETAIL,LoadBalance,FIELDS,INPUT,INPUT,INPUT,SELECT,SELECT,SELECT,BUTTON,HIDDEN,HIDDEN"
THISIFS=$IFS
IFS=","
COUNT=1
ADDCOUNT=10000
while read URL PORT LBNAME LBALGO DESTINATION DPORT
do
	write_global URL
	write_global PORT
	write_global LBNAME
	write_global LBALGO
	write_global DESTINATION
	write_global DPORT

	if [[ ${URL} == ${OLDURL} ]]
	then
		echo "DETAIL,LoadBalance,FIELDS,HIDDEN,HIDDEN,HIDDEN,HIDDEN,SELECT,SELECT,BUTTON,HIDDEN,HIDDEN"
	else
		
		if [[ ${COUNT} -gt 1 ]] 
		then
			echo "DETAIL,LoadBalance,FIELDS,HIDDEN,HIDDEN,HIDDEN,HIDDEN,SELECT,SELECT,HIDDEN,BUTTON,HIDDEN"
			echo "DETAIL,LoadBalance,${ADDCOUNT},${OLDURL},${OLDPORT},${OLDLBNAME},${OLDLBALGO},: server1 server2 server3,: ${PORTS}"
			echo "DETAIL,LoadBalance,LINE"
		fi
		ADDCOUNT=$((++ADDCOUNT))
		echo "DETAIL,LoadBalance,FIELDS,INPUT,INPUT,INPUT,SELECT,SELECT,SELECT,BUTTON,HIDDEN,HIDDEN"
		OLDURL=${URL}
		OLDPORT=${PORT}
		OLDLBNAME=${LBNAME}
		OLDLBALGO=${LBALGO}
		OLDDESTINATION=${DESTINATION}
		OLDDESTINATION=${DPORT}
	fi
	echo "DETAIL,LoadBalance,${COUNT},${URL},${PORT},${LBNAME},${LBALGO}:1 2,${DESTINATION}:server1 server2 server3,${DPORT}:${PORTS}"
	COUNT=$((++COUNT))
done < ${SYSTEMPATH}/wsdetail_LoadBalance
if [[ ${COUNT} -gt 1 ]]
then
	. /var/www/cgi-bin/tmp/globals
	echo "DETAIL,LoadBalance,FIELDS,HIDDEN,HIDDEN,HIDDEN,HIDDEN,SELECT,SELECT,HIDDEN,BUTTON,HIDDEN"
	echo "DETAIL,LoadBalance,${ADDCOUNT},${URL},${PORT},${LBNAME},${LBALGO},: server1 server2 server3,: ${PORTS}"
	echo "DETAIL,LoadBalance,LINE"
fi
echo "DETAIL,LoadBalance,FIELDS,INPUT,INPUT,INPUT,SELECT,SELECT,SELECT,HIDDEN,HIDDEN,BUTTON"
echo "DETAIL,LoadBalance,${COUNT},,,,: 1 2,: server1 server2 server3,: ${PORTS}"
IFS=$THISIFS
delete_global URL
delete_global PORT
delete_global LBNAME
delete_global LBALGO
delete_global DESTINATION
delete_global DPORT 
