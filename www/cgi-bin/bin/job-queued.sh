#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
while :
do
	THISFILE=$(find ${JOBREQUESTPATH} -type f -print | head -n 1|rev|cut -d "/" -f1|rev)	
	if [[ "${THISFILE}" != "" ]]
	then
		echo "QUEUED,$(cat ${JOBREQUESTPATH}/${THISFILE})" > ${JOBSTATUSPATH}/${THISFILE}
		mv ${JOBREQUESTPATH}/${THISFILE} ${JOBQUEUEPATH}/${THISFILE}
		log "QUEUED > ${JOBSTATUSPATH}/${THISFILE}"
	else
		sleep 1
	fi
done
