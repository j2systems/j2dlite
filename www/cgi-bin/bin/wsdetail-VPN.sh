#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

echo "DETAIL,VPN,REFRESH,Name,Url,Username,Password,Token,Group,Connect,Delete"
echo "DETAIL,VPN,FIELDS,INPUT,INPUT,INPUT,PASSWORD,SELECT,SELECT,BUTTON,BUTTON"
echo "DETAIL,VPN,STYLES,gray,gray,gray,gray,gray,gray,green,red"

COUNT=1
THISIFS=$IFS
IFS=","
while read NAME URL USERNAME PASSWORD TOKEN DEFGROUP 
do
	#THESEGROUPS=$(get_vpngroups ${URL})
	THESEGROUPS="DC02-AnyConnect-RemoteAccess Remote Split Other"
	echo "DETAIL,VPN,${COUNT},${NAME},${URL},${USERNAME},${PASSWORD},${TOKEN}:true false,${DEFGROUP}:${THESEGROUPS}"
	COUNT=$((++COUNT))
done < ${SYSTEMPATH}/vpn_details
IFS=${THISIFS}
echo "DETAIL,VPN,,,,,,false:true false,: "
