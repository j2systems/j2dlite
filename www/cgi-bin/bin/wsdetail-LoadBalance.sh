#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

[[ ! -f ${SYSTEMPATH}/wsdetail_LoadBalance ]] && touch ${SYSTEMPATH}/wsdetail_LoadBalance

echo "DETAIL,LoadBalance,REFRESH,URL,Port,LBName,LBAlgorithm,Destination,DestPort,Remove,Add,New"
echo "DETAIL,LoadBalance,FIELDS,INPUT,INPUT,INPUT,SELECT,SELECT,SELECT,BUTTON,BUTTON,BUTTON"
echo "DETAIL,LoadBalance,STYLES,gray,gray,gray,gray,gray,gray,red,green,yellow"
echo "DETAIL,LoadBalance,FIELDS,TD,TD,TD,SELECT,SELECT,SELECT,BUTTON,HIDDEN,HIDDEN"
THISIFS=$IFS
IFS=","
COUNT=1
ADDCOUNT=10000
LBALGOS="least_conn ip_hash"
SERVERLIST="server1 server2 server3"
while read URL PORT LBNAME LBALGO DESTINATION DPORT
do
	write_global URL
	write_global PORT
	write_global LBNAME
	write_global LBALGO
	write_global DESTINATION
	write_global DPORT
	if [[ ${COUNT} -eq 1 ]]
	then
		#first entry
		echo "DETAIL,LoadBalance,${COUNT},${URL},${PORT},${LBNAME},${LBALGO}:${LBALGOS},${DESTINATION}:${SERVERLIST},${DPORT}:${PORTS}"
		OLDURL=${URL}
		OLDPORT=${PORT}
		OLDLBNAME=${LBNAME}
		OLDLBALGO=${LBALGO}
		OLDDESTINATION=${DESTINATION}
		OLDDESTINATION=${DPORT}
	else
		#if same as before, use old for url, port, lbname, lgalgorithm
		if [[ ${URL} == ${OLDURL} ]]
		then
			echo "DETAIL,LoadBalance,FIELDS,HIDDEN,HIDDEN,HIDDEN,HIDDEN,SELECT,SELECT,BUTTON,HIDDEN,HIDDEN"
			echo "DETAIL,LoadBalance,${COUNT},${URL},${PORT},${LBNAME},${OLDLBALGO},${DESTINATION}:${SERVERLIST},${DPORT}:${PORTS}" 
		else
			if [[ ${COUNT} -gt 1 ]] 
			then
				echo "DETAIL,LoadBalance,FIELDS,HIDDEN,HIDDEN,HIDDEN,HIDDEN,SELECT,SELECT,HIDDEN,BUTTON,HIDDEN"
				echo "DETAIL,LoadBalance,${ADDCOUNT},${OLDURL},${OLDPORT},${OLDLBNAME},${OLDLBALGO},: ${SERVERLIST},: ${PORTS}"
				ADDCOUNT=$((++ADDCOUNT))
				echo "DETAIL,LoadBalance,LINE,${ADDCOUNT}"
				#echo "DETAIL,LoadBalance,FIELDS,HIDDEN,HIDDEN,HIDDEN,HIDDEN,SELECT,SELECT,BUTTON,HIDDEN,HIDDEN"
			fi
			ADDCOUNT=$((++ADDCOUNT))
			echo "DETAIL,LoadBalance,FIELDS,TD,TD,TD,SELECT,SELECT,SELECT,BUTTON,HIDDEN,HIDDEN"
			echo "DETAIL,LoadBalance,${COUNT},${URL},${PORT},${LBNAME},${LBALGO}:${LBALGOS},${DESTINATION}:${SERVERLIST},${DPORT}:${PORTS}"
			OLDURL=${URL}
			OLDPORT=${PORT}
			OLDLBNAME=${LBNAME}
			OLDLBALGO=${LBALGO}
			OLDDESTINATION=${DESTINATION}
			OLDDESTINATION=${DPORT}
		fi
	fi	
	COUNT=$((++COUNT))
done < ${SYSTEMPATH}/wsdetail_LoadBalance
if [[ ${COUNT} -gt 1 ]]
then
	echo "DETAIL,LoadBalance,FIELDS,HIDDEN,HIDDEN,HIDDEN,HIDDEN,SELECT,SELECT,HIDDEN,BUTTON,HIDDEN"
	echo "DETAIL,LoadBalance,${ADDCOUNT},${OLDURL},${OLDPORT},${OLDLBNAME},${OLDLBALGO},: ${SERVERLIST},: ${PORTS}"
	ADDCOUNT=$((++ADDCOUNT))
	echo "DETAIL,LoadBalance,LINE,${ADDCOUNT}"
fi
echo "DETAIL,LoadBalance,FIELDS,INPUT,INPUT,INPUT,SELECT,SELECT,SELECT,HIDDEN,HIDDEN,BUTTON"
echo "DETAIL,LoadBalance,${COUNT},,,,: ${LBALGOS},: server1 server2 server3,: ${PORTS}"
IFS=$THISIFS
delete_global URL
delete_global PORT
delete_global LBNAME
delete_global LBALGO
delete_global DESTINATION
delete_global DPORT 
