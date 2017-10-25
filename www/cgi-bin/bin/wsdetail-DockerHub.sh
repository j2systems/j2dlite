#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

echo "DETAIL,DockerHub,REFRESH,Repository,Subrepo,Username,Password,Remove:Add"
echo "DETAIL,DockerHub,FIELDS,INPUT,INPUT,INPUT,PASSWORD,BUTTON"
echo "DETAIL,DockerHub,STYLES,gray,gray,gray,gray,red:green"
THISIFS=$IFS
IFS=","
COUNT=1
while read REPO SUBREPO USERNAME PASSWORD
do
	echo "DETAIL,DockerHub,${COUNT},${REPO},${SUBREPO},${USERNAME},${PASSWORD}"
	COUNT=$((++COUNT))
done < ${SYSTEMPATH}/dockerrepo
echo "DETAIL,DockerHub,${COUNT},,,,"
IFS=$THISIFS
