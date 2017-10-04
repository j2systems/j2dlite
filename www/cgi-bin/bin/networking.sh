#!/bin/bash
#Checks docker internal network and sets it to maintain uniqueness to local environment.

BASEDIR=/var/www/cgi-bin/
source $BASEDIR/source/functions.sh
unset OLDJ2DOCKERSN
DOCKNET=j2docker
HOST=j2-iscinternal
ID=j2
HOSTNIC=$(netstat -r|grep default|tr -s " "|cut -d " " -f8)
HOSTIP=$(ifconfig ${HOSTNIC}|grep -m1 "inet "|tr -s " "|cut -d " " -f3|cut -d ":" -f2)
while [[ "$HOSTIP" == "" ]]
do 
	HOSTIP=$(ifconfig ${HOSTNIC}|grep -m1 "inet "|tr -s " "|cut -d " " -f3|cut -d ":" -f2)
	sleep 1
done
write_global HOSTIP
HOSTOCT=$(echo $HOSTIP|cut -d "." -f4)
write_global HOSTOCT

#check for existing entry in globals.  If so, record it as old for updating hosts and routing

[[ "$J2DOCKERSN" == "" ]] && J2DOCKERSN=172.$HOSTOCT.0.0 && write_global J2DOCKERSN
[[ "$(docker network ls|grep -c $DOCKNET)" == "0" ]] && docker network create j2docker --subnet $J2DOCKERSN/16

if [[ "$J2DOCKERSN" != "172.$HOSTOCT.0.0" ]]
then
	OLDJ2DOCKERSN=$J2DOCKERSN
	write_global OLDJ2DOCKERSN
fi 
J2DOCKERSN=172.$HOSTOCT.0.0
write_global J2DOCKERSN

. $BASEDIR/tmp/globals
if [[ "$OLDJ2DOCKERSN" != ""  ]]
then
	#IP address has changed.
	#Get list of containers attached to the old network
	#Detach containers from that net

	for CONTAINER in $(docker network inspect $DOCKNET|grep "Containers" -A 100|grep Name|cut -d ":" -f2|tr -d "\" ,") 
	do
		append_global CONTAINERMV $CONTAINER
		docker network disconnect $DOCKNET $CONTAINER
	done
	docker network rm $DOCKNET
	docker network create $DOCKNET --subnet $J2DOCKERSN/16
	#Attach containers
	. $BASEDIR/tmp/globals
	for CONTAINER in $CONTAINERMV
	do
		docker network connect $DOCKNET $CONTAINER
	done
	#Update hosts and routing
	. $BASEDIR/bin/mclientupdate.sh
	delete_global CONTAINERMV
	delete_global OLDJ2DOCKERSN
fi



