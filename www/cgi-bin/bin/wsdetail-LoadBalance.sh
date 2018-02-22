#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
docker ps -a --format "{{.Names}} ({{.Image}}) {{.Status}}" > ${TMPPATH}/containers             
delete_global SERVERLIST
while read NAME IMAGE STATUS                                                                                                                    
do                                                                                                                                              
        if [[ $(echo $STATUS|grep -c -e "^Up") -eq 1 ]]                                                                                         
        then
                append_global SERVERLIST $NAME                                                                                             
        fi                                                                                                                                      
done < ${TMPPATH}/containers 
[[ ! -f ${SYSTEMPATH}/wsdetail_LoadBalance ]] && touch ${SYSTEMPATH}/wsdetail_LoadBalance
sort -n ${SYSTEMPATH}/wsdetail_LoadBalance -o ${SYSTEMPATH}/wsdetail_LoadBalance
echo "DETAIL,LoadBalance,REFRESH,URL,Port,LBName,LBAlgorithm,Destination,DestPort,Weight,Remove,Add,New"
echo "DETAIL,LoadBalance,FIELDS,INPUT,INPUT,INPUT,SELECT,SELECT,SELECT,INPUT,BUTTON,BUTTON,BUTTON"
echo "DETAIL,LoadBalance,STYLES,gray,gray,gray,gray,gray,gray,gray,red,green,yellow"
echo "DETAIL,LoadBalance,FIELDS,TD,TD,TD,SELECT,SELECT,SELECT,INPUT,BUTTON,HIDDEN,HIDDEN"
. /var/www/cgi-bin/tmp/globals
THISIFS=$IFS
IFS=","
COUNT=1
ADDCOUNT=10000
LBALGOS="least_conn ip_hash"
while read URL PORT LBNAME LBALGO DESTINATION DPORT WEIGHT
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
		if [[ $(echo ${SERVERLIST}|grep -c ${DESTINATION}) -eq 0 ]]
		then
			SERVERLIST="${DESTINATION} ${SERVERLIST}"
		fi
		echo "DETAIL,LoadBalance,${COUNT},${URL},${PORT},${LBNAME},${LBALGO}:${LBALGOS},${DESTINATION}: ${SERVERLIST},${DPORT}:${PORTS},${WEIGHT}"

		OLDURL=${URL}
		OLDPORT=${PORT}
		OLDLBNAME=${LBNAME}
		OLDLBALGO=${LBALGO}
		OLDDESTINATION=${DESTINATION}
		OLDPORT=${DPORT}
		OLDWEIGHT=${WEIGHT}
	else
		#if same as before, use old for url, port, lbname, lgalgorithm
		if [[ ${URL} == ${OLDURL} ]]
		then
			echo "DETAIL,LoadBalance,FIELDS,HIDDEN,HIDDEN,HIDDEN,HIDDEN,SELECT,SELECT,INPUT,BUTTON,HIDDEN,HIDDEN"
			echo "DETAIL,LoadBalance,${COUNT},${URL},${PORT},${LBNAME},${OLDLBALGO},${DESTINATION}: ${SERVERLIST},${DPORT}:${PORTS},${WEIGHT}" 
		else
			if [[ ${COUNT} -gt 1 ]] 
			then
				echo "DETAIL,LoadBalance,FIELDS,HIDDEN,HIDDEN,HIDDEN,HIDDEN,SELECT,SELECT,INPUT,HIDDEN,BUTTON,HIDDEN"
				echo "DETAIL,LoadBalance,${ADDCOUNT},${OLDURL},${OLDPORT},${OLDLBNAME},${OLDLBALGO},: ${SERVERLIST},: ${PORTS},${WEIGHT}"
				ADDCOUNT=$((++ADDCOUNT))
				echo "DETAIL,LoadBalance,LINE,${ADDCOUNT}"
				#echo "DETAIL,LoadBalance,FIELDS,HIDDEN,HIDDEN,HIDDEN,HIDDEN,SELECT,SELECT,INPUT,BUTTON,HIDDEN,HIDDEN"
			fi
			ADDCOUNT=$((++ADDCOUNT))
			echo "DETAIL,LoadBalance,FIELDS,TD,TD,TD,SELECT,SELECT,SELECT,INPUT,BUTTON,HIDDEN,HIDDEN"
			echo "DETAIL,LoadBalance,${COUNT},${URL},${PORT},${LBNAME},${LBALGO}:${LBALGOS},${DESTINATION}: ${SERVERLIST},${DPORT}:${PORTS},${WEIGHT}"
			OLDURL=${URL}
			OLDPORT=${PORT}
			OLDLBNAME=${LBNAME}
			OLDLBALGO=${LBALGO}
			OLDDESTINATION=${DESTINATION}
			OLDPORT=${DPORT}
			OLDWEIGHT=${WEIGHT}
		fi
	fi	
	COUNT=$((++COUNT))
done < ${SYSTEMPATH}/wsdetail_LoadBalance
if [[ ${COUNT} -gt 1 ]]
then
	echo "DETAIL,LoadBalance,FIELDS,HIDDEN,HIDDEN,HIDDEN,HIDDEN,SELECT,SELECT,INPUT,HIDDEN,BUTTON,HIDDEN"
	echo "DETAIL,LoadBalance,${ADDCOUNT},${OLDURL},${OLDPORT},${OLDLBNAME},${OLDLBALGO},: ${SERVERLIST},${OLDPORT}: ${PORTS},${OLDWEIGHT}"
	ADDCOUNT=$((++ADDCOUNT))
	echo "DETAIL,LoadBalance,LINE,${ADDCOUNT}"
fi
echo "DETAIL,LoadBalance,FIELDS,INPUT,INPUT,INPUT,SELECT,SELECT,SELECT,INPUT,HIDDEN,HIDDEN,BUTTON"
echo "DETAIL,LoadBalance,${COUNT},,,,: ${LBALGOS},: ${SERVERLIST},: ${PORTS},10"
IFS=$THISIFS
delete_global URL
delete_global PORT
delete_global LBNAME
delete_global LBALGO
delete_global DESTINATION
delete_global DPORT
delete_global SERVERLIST
bash ${BINPATH}/nginxlb.sh
bash ${BINPATH}/mclientupdate.sh 
