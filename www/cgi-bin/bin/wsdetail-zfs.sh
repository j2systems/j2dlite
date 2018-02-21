#!/bin/bash
#
# Creates table from zfs list

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

log "Updating zfs status"

#Clear current info

for DATAOUT in zfsstats zfspools dockervols zfsusage
do 
	[[ -f ${TMPPATH}/${DATAOUT} ]] && rm -rf ${TMPPATH}/${DATAOUT}
	touch ${TMPPATH}/${DATAOUT}
done

zfs get -o name,value -H used|sort -r > ${TMPPATH}/zfsusage
zpool list> ${TMPPATH}/zfspools
docker inspect --format='IMAGE,{{json .GraphDriver.Data.Dataset}},{{.RepoTags}}' $(docker images -qa)|tr -d "\"[]" > ${TMPPATH}/dockervols
docker inspect --format='CONTAINER,{{json .GraphDriver.Data.Dataset}},{{.Name}}' $(docker ps -qa)|tr -d "\"[]"|sed "s, /, ,g" >> ${TMPPATH}/dockervols


#cross reference 
#THISIFS=$IFS
#IFS=","
#Read zfs vols.  Find vol name in docker vols.  report accordingly
echo "DETAIL,zfs,REFRESH,Volume,Size,Type,Reference"
echo "DETAIL,zfs,FIELDS,TD,TD,TD,TD"
echo "DETAIL,zfs,STYLES,white,white,white,white"
COUNT=0
while read NAME USED
do
	
        unset CROSSREF
	unset STATUS
	unset TYPE
	if [[ $(echo ${NAME}|grep -c "@") -ne 0 ]]
	then
		THISZFSVOL=$(echo "${NAME}"|cut -d "@" -f1)
		TYPE="snapshot"
	else
		THISZFSVOL=${NAME}
		TYPE="base"
	fi
	VOLLIST=$(grep ",${THISZFSVOL}," ${TMPPATH}/dockervols|head -n 1)
        CROSSREF=$(echo ${VOLLIST}|cut -d "," -f3)
	DOCKERREF=$(echo ${VOLLIST}|cut -d "," -f1)
        if [[ "${CROSSREF}" != "" ]]
        then
		COUNT=$((++COUNT))
		[[ "$(echo ${CROSSREF}|cut -c 1)" == "/" ]] && CROSSREF=$(echo ${CROSSREF}|cut -c 2-)
		echo "DETAIL,zfs,${COUNT},${NAME},${USED},${TYPE},(${DOCKERREF}) ${CROSSREF}"
	else
		if [[ $(echo "${THISZFSVOL}"|grep -c "directIO") -eq 1 ]]
		then
			COUNT=$((++COUNT))
			echo "DETAIL,zfs,${COUNT},${NAME},${USED},volume,XFS for direct io"

		# native docker volume || "${THISZFSVOL}" == "docker" ]]
		else
			COUNT=$((++COUNT))
			echo "DETAIL,zfs,${COUNT},${NAME},${USED},no ref,no ref"
		fi

		#echo "${NAME} - god knows"
       fi
done < ${TMPPATH}/zfsusage

