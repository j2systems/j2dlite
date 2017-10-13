#/bin/bash

# Reads files in job queue directory and returns the associated status from job ststus dir

. /var/www/cgi-bin/tmp/globals

unset THISJOB
while read JOB
do
	THISDETAIL=$(cat ${JOB})
	THISSTATUS=$(echo ${THISDETAIL}|cut -d "," -f1)
	THISMC=$(echo ${THISDETAIL}|cut -d "," -f2)
	THISACTION="$(echo ${THISDETAIL}|cut -d "," -f3-)"
	echo "JOBINFO,${THISMC},${THISACTION},${THISSTATUS}"
done < <(find ${JOBSTATUSPATH} -type f)
[[ "${THISDETAIL}" == "" ]] && echo "JOBINFO,,idle idle idle,IDLE"
