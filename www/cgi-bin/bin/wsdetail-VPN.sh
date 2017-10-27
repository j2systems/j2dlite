#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

echo "DETAIL,VPN,REFRESH,Name,Url,Username,Password,Token,Group,Connect:Add,Remove:"
echo "DETAIL,VPN,FIELDS,INPUT,INPUT,INPUT,PASSWORD,SELECT,SELECT,BUTTON,BUTTON"
echo "DETAIL,VPN,STYLES,gray,gray,gray,gray,gray,gray,green:yellow,red:"

COUNT=1
THISIFS=$IFS
IFS=","
while read -u3 NAME URL USERNAME PASSWORD TOKEN DEFGROUP 
do
	unset THESEGROUPS
	THESEGROUPS=$(get_vpngroups "${URL}")
	[[ "${DEFGROUP}" == "(Default)" ]] && DEFGROUP=$(echo ${THESEGROUPS}|cut -d " " -f1) && log "defgroup: ${DEFGROUP}-bob"
	echo "DETAIL,VPN,${COUNT},${NAME},${URL},${USERNAME},${PASSWORD},${TOKEN}:true false,${DEFGROUP}:${THESEGROUPS}"
	COUNT=$((++COUNT))
done 3<${SYSTEMPATH}/wsdetail_VPN
IFS=${THISIFS}
echo "DETAIL,VPN,${COUNT},,,,,false:true false,(Default):(Default)"
