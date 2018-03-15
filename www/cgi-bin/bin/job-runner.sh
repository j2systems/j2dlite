#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
while :
do
	#find jobs -type f -printf '%T@ %p\n' | sort
	THISFILE=$(find ${JOBQUEUEPATH} -type f -print | head -n 1|rev|cut -d "/" -f1|rev)	
	if [[ "${THISFILE}" != "" ]]
	then
		THISJOB=$(cat ${JOBQUEUEPATH}/${THISFILE})
		echo "RUNNING,${THISJOB}" > ${JOBSTATUSPATH}/${THISFILE}
		REQUESTOR=$(echo ${THISJOB}|cut -d "," -f1)
		REQUEST="$(echo ${THISJOB}|cut -d "," -f2-)"
		ACTION=$(echo ${REQUEST}|cut -d" " -f2)
		CONTAINER=$(echo ${REQUEST}|cut -d" " -f3)
		case ${ACTION} in
			"start")
				docker start ${CONTAINER}
				OUTCOME=$?
				if [[ ${OUTCOME} -eq 0 ]]
				then
					${BINPATH}/mclientupdate.sh
					echo "COMPLETE,${THISJOB}" > ${JOBSTATUSPATH}/${THISFILE}
				else
					echo "FAILED,${THISJOB}" > ${JOBSTATUSPATH}/${THISFILE}
				fi
				;;
			"stop")
				docker stop ${CONTAINER}
				OUTCOME=$?
				[[ ${OUTCOME} -eq 0 ]] && ${BINPATH}/mclientupdate.sh
				CONTAINERDIR=$(docker inspect --format='{{json .GraphDriver.Data.Mountpoint}}' ${CONTAINER})
				log "Checking for clean stop of ${CONTAINER}"
				if [[ -d ${CONTAINERDIR} ]] 
				then
					if [[ -z "$(ls -A ${CONTAINERDIR})" ]]
					then
						log "Removing ${CONTAINERDIR}"
						rmdir ${CONTAINERDIR} 
					fi
				fi
				if [[ -d ${CONTAINERDIR} ]] 
				then
					echo "FAILED,${THISJOB}" > ${JOBSTATUSPATH}/${THISFILE} 
					log "There seems to be a problem with ${CONTAINER}"
					log "It's container directory,"
					log "${CONTAINERDIR}"
					log "is not empty, but needs to be removed for further functionality"
				else
					echo "COMPLETE,${THISJOB}" > ${JOBSTATUSPATH}/${THISFILE}
					log "${CONTAINER} stopped cleanly."

				fi
				;;
			"delete")
				docker rm ${CONTAINER}
				OUTCOME=$?
				if [[ ${OUTCOME} -eq 0 ]]
				then
					${BINPATH}/mclientupdate.sh
					echo "COMPLETE,${THISJOB}" > ${JOBSTATUSPATH}/${THISFILE}
				else
					echo "FAILED,${THISJOB}" > ${JOBSTATUSPATH}/${THISFILE}
				fi
				;;
			"commit")
				TAG=$(echo ${CONTAINER}|cut -d "=" -f2)
				CONTAINER=$(echo ${CONTAINER}|cut -d "=" -f1)
				docker commit ${CONTAINER} j2systems/docker:${TAG}
				OUTCOME=$?
				if [[ ${OUTCOME} -eq 0 ]]
				then
					echo "COMPLETE,${THISJOB}" > ${JOBSTATUSPATH}/${THISFILE}
				else
					echo "FAILED,${THISJOB}" > ${JOBSTATUSPATH}/${THISFILE}
				fi
				;;
			"export")
				SHARESUBDIR=$(find ${SHAREDIR} -maxdepth 1 -mindepth 1 -type d|head -n 1)
				if [[ ${SHARESUBDIR} != "" ]]
				then
					EXPORTDIR=${SHARESUBDIR}/${HOSTNAME}/docker.exports
					[[ ! -d $EXPORTDIR ]] && mkdir -p $EXPORTDIR
					# Export
					log "Starting export of ${CONTAINER} to ${EXPORTDIR}"
					log "docker export -o ${EXPORTDIR}/${CONTAINER}.tar"
					docker export -o "${EXPORTDIR}/${CONTAINER}.tar" ${CONTAINER}
					if [[ -f ${EXPORTDIR}/${CONTAINER}.tar ]]
					then
						echo "COMPLETE,${THISJOB}" > ${JOBSTATUSPATH}/${THISFILE}
					else
						echo "FAILED,${THISJOB}" > ${JOBSTATUSPATH}/${THISFILE}
					fi
				else
					echo "FAILED,${THISJOB}" > ${JOBSTATUSPATH}/${THISFILE}
					log "No shared directory available for export."
				fi
				;;
			*)
				OUTCOME="Unhandled"
				;;
		esac
		log "${REQUEST} - ${OUTCOME}. ${THISJOB} > ${STATUSDIR}/${THISFILE}"
		rm -rf ${JOBQUEUEPATH}/${THISFILE}
		bash ${BINPATH}/job-remove.sh ${THISFILE} &
	else
		sleep 1
	fi
done
