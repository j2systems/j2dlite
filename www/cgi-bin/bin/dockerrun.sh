#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
# re-read container names
delete_global CONTAINERS
while read CONTAINERNAME
do
	append_global CONTAINERS $CONTAINERNAME
done < <(docker ps -a --format "{{.Names}}")

sed -i "s/&/\n/g" ${TMPPATH}/run
INTEGRATE=false
while read DETAIL
do
	if [[ $(echo "$DETAIL"|grep -c "INT") -eq 0 && "$(echo $DETAIL|cut -d "=" -f1)" != "RUN" ]]
	then
        	if [[ "$(echo $DETAIL|cut -d "=" -f2)" != "" ]] 
        	then
			THISIMAGE=$(echo $DETAIL|cut -d "=" -f1|sed "s,_FSLASH_,/,g"|sed "s,_COLON_,:,g")
        	fi
		IMAGENAME=${THISIMAGE}
		CALLED=$(echo ${DETAIL}|cut -d "=" -f2|tr "+" " ")
		for HOST in ${CALLED}
		do
			. tmp/globals
			if [[ $(echo ${CONTAINERS}|grep -c ${HOST}) -eq 1 ]]
			then
				echo "Cannot run ${IMAGETORUN} as ${HOST}.  ${HOST} is already in use"
			else
				#add new hostname to global 
				append_global NEWCONTAINERS ${HOST}
				if [[ "$(imagelocation ${IMAGENAME})" == "REMOTE" ]]
				then
					dockerlogin
					echo "Pulling image from repository"
					docker pull ${IMAGENAME} 2>&1
					. ${BINPATH}/image_array.sh
				fi
				echo "Spinning up ${HOST}"
				. tmp/globals
				echo "Entrypoint: $(docker inspect --format='{{json .Config.Entrypoint}}' $IMAGENAME|tr -d "[]")"
				ENTRYPOINT=$(docker inspect --format='{{json .Config.Entrypoint}}' $IMAGENAME|tr -d " []\"")
				if [[ "${ENTRYPOINT}" == "" || "${ENTRYPOINT}" == "null" ]]
				then
					echo "docker run -id --name $HOST -h $HOST  --network j2docker -v $SHAREDIR:/mnt/host $IMAGENAME /bin/sh"
					docker run -itd --name $HOST -h $HOST  --network j2docker -v $SHAREDIR:/mnt/host $IMAGENAME /bin/sh 2>&1
				else
					if [[ "$ENTRYPOINT" == "/sbin/pseudo-init" ]]
					then
						echo "docker run -d --name $HOST -h $HOST --network j2docker -v $SHAREDIR:/mnt/host -v /InterSystems/jrnalt -v  /InterSystems/jrnpri $IMAGENAME"
						docker run -d --name $HOST -h $HOST --network j2docker -v $SHAREDIR:/mnt/host -v /InterSystems/jrnalt -v  /InterSystems/jrnpri $IMAGENAME 2>&1
					else
						echo "docker run -d --name $HOST -h $HOST --network j2docker -v $SHAREDIR:/mnt/host $IMAGENAME"
						docker run -d --name $HOST -h $HOST --network j2docker -v $SHAREDIR:/mnt/host $IMAGENAME
					fi
				fi
			fi	
		done
	fi
done < <(cat ${TMPPATH}/run)
rm -f ${TMPPATH}/run
echo "Connectivity updating..."
echo "SCRIPT END"
bash ${BINPATH}/mclientupdate.sh
bash ${BINPATH}/zfs-status.sh
dockerlogout
