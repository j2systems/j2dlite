#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

echo "DETAIL,MClients,REFRESH,Machine,Username,Type,Integrate,Studio,Atellier,Remove"
echo "DETAIL,MClients,FIELDS,TD,TD,TD,SELECT,SELECT,SELECT,BUTTON"
echo "DETAIL,MClients,STYLES,gray,gray,gray,gray,gray,gray,red"
THISIFS=$IFS
IFS=","
COUNT=1
while read MACHINE USERNAME TYPE INTEGRATE STUDIO ATELLIER
do
	echo "DETAIL,MClients,${COUNT},${MACHINE},${USERNAME},${TYPE},${INTEGRATE}:true false,${STUDIO}:true false,${ATELLIER}:true false"
	COUNT=$((++COUNT))
done < ${SYSTEMPATH}/wsdetail_MClients
IFS=$THISIFS
