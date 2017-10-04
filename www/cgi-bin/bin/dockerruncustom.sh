#!/bin/bash
ROOTDIR=/var/www/cgi-bin
cd $ROOTDIR
# source functions
if [[ -f tmp/run ]]
then
	source source/functions.sh 2>&1
	dockerlogin
	delete_global MANAGEMENTHOSTS
	delete_global CONTAINERS
	delete_global NEWCONTAINERS

# check routing tables!

	# re-read container names
	docker ps -a --format "{{.Names}}" > tmp/containers
	while read CONTAINERNAME
	do
		append_global CONTAINERS $CONTAINERNAME
	done < tmp/containers

	INTEGRATE=false
	DETAIL=$(cat tmp/run)
	#echo $DETAIL
	IMAGENAME=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f1|sed "s,_FSLASH_,/,g"|sed "s,_COLON_,:,g")
       	HOST=$(echo $DETAIL|cut -d "&" -f1|cut -d "=" -f2)
	CUSTOMCOMMAND=$(echo $DETAIL|cut -d "&" -f2|cut -d "=" -f2|sed "s,+, ,g"|sed "s,%22,\\\",g"|sed "s,%3D,=,g"|sed "s,%26,\&,g"|sed "s,%27,\',g"|sed "s,%2B,+,g"|sed "s,%2F,/,g"|sed "s,%40,\@,g")
	ENTRYPOINT=$(echo $DETAIL|cut -d "&" -f3|cut -d "=" -f2|sed "s,+, ,g"|sed "s,%22,\",g"|sed "s,%3D,=,g"|sed "s,%26,\&,g"|sed "s,%27,\',g"|sed "s,%2B,+,g"|sed "s,%2F,/,g"|sed "s,%40,\@,g")
	echo $CUSTOMCOMMAND
	echo $ENTRYPOINT
	. tmp/globals
	#add new hostname to global 
	status "Spinning up $HOST"
	echo "Spinning up $HOST"
	. tmp/globals
	echo "Entrypoint: ${ENTRYPOINT}"
	if [[ "$ENTRYPOINT" == "" || "$ENTRYPOINT" == "null" ]]
	then
		echo "docker run -id --name $HOST -h $HOST  --network j2docker -v $SHAREDIR:/mnt/host ${CUSTOMCOMMAND} $IMAGENAME /bin/sh"
		docker run -itd --name $HOST -h $HOST  --network j2docker -v $SHAREDIR:/mnt/host ${CUSTOMCOMMAND} $IMAGENAME /bin/sh 2>&1
	else
		if [[ "$ENTRYPOINT" == "/sbin/pseudo-init" ]]
			then
				echo "docker run -d --name $HOST -h $HOST --network j2docker -v $SHAREDIR:/mnt/host -v /InterSystems/jrnalt -v  /InterSystems/jrnpri ${CUSTOMCOMMAND} $IMAGENAME"
				docker run -d --name $HOST -h $HOST --network j2docker -v $SHAREDIR:/mnt/host -v /InterSystems/jrnalt -v  /InterSystems/jrnpri ${CUSTOMCOMMAND} $IMAGENAME 2>&1
			else
				echo "docker run -d --name $HOST -h $HOST --network j2docker -v $SHAREDIR:/mnt/host ${CUSTOMCOMMAND} $IMAGENAME ${ENTRYPOINT}"
				docker run -d --name $HOST -h $HOST --network j2docker -v $SHAREDIR:/mnt/host ${CUSTOMCOMMAND} $IMAGENAME
			fi
		fi
	fi	
	echo "Client update initiated..."

# remove run,etc
	rm -f tmp/run
	while [[ -f tmp/trigger ]]
	do
		sleep 0.5
	done
	echo "mclientupdate.sh" > tmp/trigger
	while [[ -f tmp/trigger ]]
	do
		sleep 0.5
	done
	echo "zfs-status.sh" > tmp/trigger
	echo "SCRIPT END"
	dockerlogout
fi
