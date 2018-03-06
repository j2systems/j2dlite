#!/bin/bash

# Read globals to get sytem directories

WWWROOT=/var/www/cgi-bin
TMPPATH=${WWWROOT}/tmp
. ${TMPPATH}/globals

# Disable ssh host checking
echo -e "Host *\nStrictHostKeyChecking no" > /root/.ssh/config

#Websocket
websocketd --port 4201 ${BINPATH}/listener.sh &

#Task runner
bash ${BINPATH}/job-queued.sh &
bash ${BINPATH}/job-runner.sh &

# Sync time
ntpd -q -p 0.uk.pool.ntp.org

#Start apache                                                                              
#apachectl -k start 

# Start Docker

export DOCKER_RAMDISK=true                                                                 
dockerd &
DOCKERSTATUS=$(docker info 2>&1|grep -c CPU)
while [[ ${DOCKERSTATUS} -eq 0 ]]
do
	echo -n "."
	sleep 1
	DOCKERSTATUS=$(docker info 2>&1|grep -c CPU)
done

#Start apache
apachectl -k start

#configure networking and iptables
bash ${BINPATH}/networking.sh
bash ${BINPATH}/config.sh
