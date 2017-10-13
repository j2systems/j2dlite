#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

if [[ -f ${TMPPATH}/run ]]
then
	dockerlogin
	delete_global CONTAINERS
	# re-read container names
	while read CONTAINERNAME
	do
		append_global CONTAINERS ${CONTAINERNAME}
	done < <(docker ps -a --format "{{.Names}}")
	INTEGRATE=false
	DETAIL=$(cat ${TMPPATH}/run)
	#echo $DETAIL
	IMAGENAME=$(echo ${DETAIL}|cut -d "&" -f1|cut -d "=" -f1|sed "s,_FSLASH_,/,g"|sed "s,_COLON_,:,g")
       	HOST=$(echo ${DETAIL}|cut -d "&" -f1|cut -d "=" -f2)
	CUSTOMCOMMAND=$(echo ${DETAIL}|cut -d "&" -f2|cut -d "=" -f2|sed "s,+, ,g"|sed "s,%22,\\\",g"|sed "s,%3D,=,g"|sed "s,%26,\&,g"|sed "s,%27,\',g"|sed "s,%2B,+,g"|sed "s,%2F,/,g"|sed "s,%40,\@,g")
	ENTRYPOINT=$(echo ${DETAIL}|cut -d "&" -f3|cut -d "=" -f2|sed "s,+, ,g"|sed "s,%22,\",g"|sed "s,%3D,=,g"|sed "s,%26,\&,g"|sed "s,%27,\',g"|sed "s,%2B,+,g"|sed "s,%2F,/,g"|sed "s,%40,\@,g")
	echo "Custom command: ${CUSTOMCOMMAND}"
	#add new hostname to global 
	echo "Spinning up $HOST"
	. ${TMPPATH}/globals
	echo "Entrypoint: ${ENTRYPOINT}"
	if [[ "${ENTRYPOINT}" == "" || "${ENTRYPOINT}" == "null" ]]
	then
		echo "docker run -id --name ${HOST} -h ${HOST}  --network j2docker -v ${SHAREDIR}:/mnt/host ${CUSTOMCOMMAND} ${IMAGENAME} /bin/sh"
		docker run -itd --name ${HOST} -h ${HOST}  --network j2docker -v ${SHAREDIR}:/mnt/host ${CUSTOMCOMMAND} ${IMAGENAME} /bin/sh 2>&1
	else
		if [[ "${ENTRYPOINT}" == "/sbin/pseudo-init" ]]
			then
				echo "docker run -d --name ${HOST} -h ${HOST} --network j2docker -v ${SHAREDIR}:/mnt/host -v /InterSystems/jrnalt -v  /InterSystems/jrnpri ${CUSTOMCOMMAND} ${IMAGENAME}"
				docker run -d --name ${HOST} -h ${HOST} --network j2docker -v ${SHAREDIR}:/mnt/host -v /InterSystems/jrnalt -v  /InterSystems/jrnpri ${CUSTOMCOMMAND} ${IMAGENAME} 2>&1
			else
				echo "docker run -d --name ${HOST} -h ${HOST} --network j2docker -v ${SHAREDIR}:/mnt/host ${CUSTOMCOMMAND} ${IMAGENAME} ${ENTRYPOINT}"
				docker run -d --name ${HOST} -h ${HOST} --network j2docker -v ${SHAREDIR}:/mnt/host ${CUSTOMCOMMAND} ${IMAGENAME} ${ENTRYPOINT}
			fi
		fi
	fi	
	echo "Client update initiated..."
	echo "SCRIPT END"
	rm -f ${TMPPATH}/run 
	bash ${BINPATH}/mclientupdate.sh
	bash ${BINPATH}/zfs-status.sh
	dockerlogout
fi
