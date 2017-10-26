#!/bin/bash
# source functions
source source/functions.sh

delete_global MANAGEMENTHOSTS
delete_global CONTAINERS
delete_global NEWCONTAINERS
read INPUTTEXT

# check routing tables!

#display page
cat base/header

# re-read management and get hosts file from each
while read CLIENT USERNAME TYPE STATUS
do
	append_global MANAGEMENTHOSTS $CLIENT
	get_hosts $USERNAME $CLIENT $TYPE
done < <(grep "true" tmp/management_hosts)

# re-read container names
while read CONTAINERNAME
do
	append_global CONTAINERS $CONTAINERNAME
done < <(docker ps -a --format "{{.Names}}")
echo "<html><body><a href=\"./summary.cgi\">Home</a>"
while read DETAIL
do
	INTEGRATE=false
	if [[ $(echo "$DETAIL"|grep -c "INT") -eq 0 ]]
	then
        	if [[ "$(echo $DETAIL|cut -d "=" -f2)" != "" ]]
        	then
                	THISIMAGE=$(echo $DETAIL|cut -d "=" -f1)
			if [[ $(echo $INPUTTEXT|grep -c "$THISDETAIL-INT=on") -eq 1 ]]
                	then
                        	INTEGRATE=true
			fi
        	fi
		IMAGENAME=$(echo $THISIMAGE|cut -d "-" -f1|tr "_" "/")
		IMAGETAG=$(echo $THISIMAGE|cut -d "-" -f2-)
		CALLED=$(echo $DETAIL|cut -d "=" -f2|tr "+" " ")
		for HOST in $CALLED
		do
			. tmp/globals
			if [[ $(echo $CONTAINERS|grep -c $HOST) -eq 1 ]]
			then
				echo "Cannot run $IMAGETORUN as \"$HOST\".  \"$HOST\" is already in use<br>"
			else
				#add new hostname to global 
				append_global NEWCONTAINERS $HOST
				#spin up a container
				LOCATION=$(grep "$IMAGENAME $IMAGETAG" tmp/images|cut -d " " -f3)

				if [[ "$LOCATION" == "REMOTE" ]] 
				then
					echo "$IMAGENAME:$IMAGETAG" > tmp/dockerpull
					echo " nohup sh bin/dockerpull.sh \"$IMAGENAME:$IMAGETAG\""				
				fi
				echo "docker run -itd --name $HOST -h $HOST --network j2docker -v $SHAREDIR:/mnt/host -v /InterSystems/jrnalt -v  /InterSystems/jrnpri $IMAGENAME:$IMAGETAG /bin/sh 2>&1"
				docker run -itd --name $HOST -h $HOST --network j2docker -v $SHAREDIR:/mnt/host -v /InterSystems/jrnalt -v  /InterSystems/jrnpri $IMAGENAME:$IMAGETAG /bin/sh 2>&1
				#for each management hosts, add to hosts file
				for SERVER in $MANAGEMENTHOSTS
				do
					TYPE=grep $SERVER tmp/management_hosts|cut -d 
					amend_container $SERVER $HOST
				done
				echo "<br>"
			fi
		done
	fi
done < <(echo $INPUTTEXT|sed "s/&/\n/g")
# re-read globals
. tmp/globals
# update registry on windows clients
while read CLIENT USERNAME SYSTEM STATUS
do
	if [[ "$SYSTEM" == "WINDOWS" ]]
	then 
		for CONTAINER in $NEWCONTAINERS
		do
			add_registry $USERNAME $CLIENT $CONTAINER
		done
	fi
	put_hosts $USERNAME $CLIENT $SYSTEM
done < <(grep "true" tmp/management_hosts)

cat base/footer		

