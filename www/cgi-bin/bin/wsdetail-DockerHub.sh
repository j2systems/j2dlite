#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

echo "DETAIL,DockerHub,REFRESH,Repository,Subrepo,Username,Password"
echo "DETAIL,DockerHub,FIELDS,INPUT,INPUT,INPUT,PASSWORD"
echo "DETAIL,DockerHub,STYLES,gray,gray,gray,gray"
THISIFS=$IFS
IFS=","
COUNT=1
while read REPO SUBREPO USERNAME PASSWORD
do
	echo "DETAIL,DockerHub,${COUNT},${REPO},${SUBREPO},${USERNAME},${PASSWORD}"
	COUNT=$((++COUNT))
done < ${SYSTEMPATH}/wsdetail_DockerHub
if [[ ${COUNT} -eq 1 ]]
then
	echo "DETAIL,DockerHub,${COUNT},,,,"
fi
IFS=$THISIFS
