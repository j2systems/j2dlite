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
[[ "$(docker volume ls|grep common)" == "" ]] && docker volume create common
while read DETAIL
do
	ROWREFERENCE=$(echo ${DETAIL}|cut -d "=" -f1)
	NAMES=$(echo ${DETAIL}|cut -d "=" -f2)
	if [[ "${ROWREFERENCE}" != "RUN" &&  "${NAMES}" != "" ]]
	then	
		THISIMAGE=$(sed "${ROWREFERENCE}q;d" ${TMPPATH}/images)
		REPONAME=$(echo ${THISIMAGE}|cut -d " " -f1)
		IMAGENAME=$(echo ${THISIMAGE}|cut -d " " -f2)
		LOCATION=$(echo ${THISIMAGE}|cut -d " " -f3)
		CALLED=$(echo ${NAMES}|cut -d "=" -f2|tr "+" " ")
		for HOST in ${CALLED}
		do
			. ${TMPPATH}/globals
			if [[ $(echo ${CONTAINERS}|grep -c ${HOST}) -eq 1 ]]
			then
				echo "Cannot run ${IMAGETORUN} as ${HOST}.  ${HOST} is already in use"
			else
				#add new hostname to global 
				append_global NEWCONTAINERS ${HOST}
				if [[ "${LOCATION}" == "REMOTE" ]]
				then
					dockerlogin
					echo "Pulling image from repository"
					docker pull ${IMAGENAME} 2>&1
					. ${BINPATH}/image_array.sh
				fi
				if [[ "${LOCATION}" == "GITLAB" ]]
				then
					THISUSER=$(head -n 1 /var/www/cgi-bin/system/wsdetail_GitLab|cut -d "," -f1)
					THISPASS=$(head -n 1 /var/www/cgi-bin/system/wsdetail_GitLab|cut -d "," -f2)
					docker login -u ${THISUSER} -p ${THISPASS} https://gitlab.j2interactive.com:5002
					echo "docker pull ${REPONAME}:${IMAGENAME}"
					docker pull ${REPONAME}:${IMAGENAME}
					docker logout
					unset THISPASS
					unset THISUSER
				fi
				echo "Spinning up ${HOST}"
				. ${TMPPATH}/globals
				echo "Entrypoint: $(docker inspect --format='{{json .Config.Entrypoint}}' ${REPONAME}:${IMAGENAME}|tr -d "[]")"
				ENTRYPOINT=$(docker inspect --format='{{json .Config.Entrypoint}}' ${REPONAME}:${IMAGENAME}|tr -d " []\"")
				if [[ "${ENTRYPOINT}" == "" || "${ENTRYPOINT}" == "null" ]]
				then
					echo "docker run -id --name $HOST -h $HOST  --network j2docker -v $SHAREDIR:/mnt/host -v common:/common ${REPONAME}:${IMAGENAME} /bin/sh"
					docker run -itd --name $HOST -h $HOST  --network j2docker -v $SHAREDIR:/mnt/host -v common:/common ${REPONAME}:${IMAGENAME} /bin/sh 2>&1
				else
					if [[ "$ENTRYPOINT" == "/sbin/pseudo-init" ]]
					then
						echo "docker run -d --name $HOST -h $HOST --network j2docker -v common:/common -v $SHAREDIR:/mnt/host -v /InterSystems/jrnalt -v  /InterSystems/jrnpri ${REPONAME}:${IMAGENAME}"
						docker run -d --name $HOST -h $HOST --network j2docker -v common:/common -v $SHAREDIR:/mnt/host -v /InterSystems/jrnalt -v  /InterSystems/jrnpri ${REPONAME}:${IMAGENAME} 2>&1
					else
						echo "docker run -d --name $HOST -h $HOST --network j2docker -v common:/common -v $SHAREDIR:/mnt/host ${REPONAME}:${IMAGENAME}"
						docker run -d --name $HOST -h $HOST --network j2docker -v common:/common -v $SHAREDIR:/mnt/host ${REPONAME}:${IMAGENAME}
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
dockerlogout
