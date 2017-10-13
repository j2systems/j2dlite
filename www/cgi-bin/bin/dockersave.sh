#!/bin/bash
#
# Saves an image. 

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

SAVEPATH=$(echo $1|cut -d "," -f1)
SAVECONTAINER=$(echo $1|cut -d "," -f2)

SHARESUBDIR=$(find ${SHAREDIR} -maxdepth 1 -mindepth 1 -type d|head -n 1)
if [[ ${SHARESUBDIR} != "" ]]
then
	SAVEDIR=${SHARESUBDIR}/${HOSTNAME}/docker.saves
	[[ ! -d ${SAVEDIR} ]] && mkdir -p ${SAVEDIR}

#	Save Image
	echo "Starting save of ${SAVECONTAINER} to ${SAVEDIR}"
	echo "docker save -o ${SAVEDIR}/${SAVECONTAINER}.tar ${SAVECONTAINER}"
	docker save -o "${SAVEDIR}/${SAVECONTAINER}.tar" ${SAVECONTAINER} 2>&1
	if [[ -f ${SAVEDIR}/${SAVECONTAINER}.tar ]]
	then
		echo "${SAVECONTAINER} saved to ${SAVEDIR}."
	else
		echo "It all went wrong.  Not saved."
	fi
	echo "SCRIPT END"

