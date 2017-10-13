#!/bin/bash

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

# docker volume management
# Initialise

[[ -f /tmp/dockervolinfo ]] && rm -f /tmp/dockervolinfo
[[ -f /tmp/dockergraphinfo ]] && rm -f /tmp/dockergraphinfo
for CONTAINER in $(docker ps -aq)
do
	if [[ "$(docker inspect $CONTAINER|jq '.[].State.Running')" == "false" ]]
	then
		CONTAINERNAME=$(docker inspect ${CONTAINER}|jq '.[].Name' |tr -d "/")
		GRAPH=$(docker inspect ${CONTAINER}|jq '.[].GraphDriver|.Data|.Dataset'|tr -d "\"")
		if [[ -d /var/lib/docker/zfs/graph/${GRAPH} ]]
		then
			log "Found volume ${GRAPH} for offline ${CONTAINERNAME}.  Deleteing..."
			rm -rf /var/lib/docker/zfs/graph/${GRAPH}
		fi
	fi
done
# remove folders from stopped containers

while read VOLUME STATUS
do
	if [[ "${STATUS}" == "exited" ]]
	then
		if [[ -d ${VOLUME} ]]
		then
			if [[ "$(ls ${VOLUME})" == "" ]]
			then 
				log "Found empty ${VOLUME} from exited container. Removing."
				rm -rf ${VOLUME}
			fi
		fi
	fi
done < <(docker inspect $(docker ps -aq)|jq -r '.[]|[.GraphDriver.Data.Mountpoint,.State.Status]|join(" ")')

# Give dockers prune algorithm a chance
log "docker volume prune -f"
docker volume prune -f

# Remove anything that isn't referenced
log "Removing any lingering volumes..."
# Collate information
# graph (images/containers) and volumes
#
# volumes

docker inspect $(docker ps -aq)|jq '.[].Mounts|.[].Name'|grep -v "null"|tr -d "\"" >> /tmp/dockervolinfo 
docker inspect $(docker images -aq)|jq '.[].Mounts|.[].Name' 2>/dev/null |grep -v "null"|tr -d "\"" >> /tmp/dockervolinfo

# container and images

docker inspect $(docker ps -aq)|jq '.[].GraphDriver|.Data|.Dataset'|tr -d "\"" >> /tmp/dockervolinfo
docker inspect $(docker images -aq)|jq '.[].GraphDriver|.Data|.Dataset'|tr -d "\"" >> /tmp/dockervolinfo 

sed -i "s,docker/,,g" /tmp/dockervolinfo

while read SIZE VOLUMEPATH
do 
	VOLUME=$(echo ${VOLUMEPATH}|rev|cut -d "/" -f1|rev)
	if [[ ! -d ${VOLUME}-init ]] && [[ $(grep -c ${VOLUME} /tmp/dockervolinfo) -eq 0 ]]
	then
		log "${VOLUME} found with no associated -init, image or container. Removing..."
		rm -rf /var/lib/docker/zfs/graph/${VOLUME}
	fi
done< <(find /var/lib/docker/zfs/graph/ -maxdepth 1 -mindepth 1 -type d ! -name "*-init" -exec du {} -d 0 \;)
log "...completed. Calling zfs update."
 
# Update zfs info

bash ${BINPATH}/zfs-status.sh
