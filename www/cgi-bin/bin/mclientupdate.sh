#!/bin/bash
#
# All-in-one script to update management clients.
# Called at boot and when summary and system pages are opened

. /var/www/cgi-bin/tmp/globals
SCRIPTBASE=/var/www/cgi-bin
SOMETHINGTODO=false
source ${WWWROOT}/source/functions.sh

docker ps -a --format "{{.Names}} ({{.Image}}) {{.Status}}" > ${TMPPATH}/containers

delete_global THESECONTAINERS
while read NAME IMAGE STATUS
do
	if [[ $(echo $STATUS|grep -c -e "^Up") -eq 1 ]]
	then
		SOMETHINGTODO=true
		append_global THESECONTAINERS $NAME
	fi
done < ${TMPPATH}/containers
. /var/www/cgi-bin/tmp/globals
if [[ "${SOMETHINGTODO}" == "true" ]]
then
	while read -u3 MCHOST USERNAME TYPE INTEGRATE STUDIO ATELIER
	do
		log "Read ${MCHOST}, ${INTEGRATE}"
		if [[ "${INTEGRATE}" == "true" ]]
		then
			if [[ "$(client_status ${MCHOST})" == "online" ]]
			then
				log "${MCHOST} at update"
				#update routing
				mcmanage ${MCHOST} route check
				#purge hosts
				mcmanage ${MCHOST} hosts purge
				#purge studio/atelier
				[[ "${STUDIO}" == "true" ]] && mcmanage ${MCHOST} studio purge
				[[ "${ATELIER}" == "true" ]] && mcmanage ${MCHOST} atelier purge
				mcmanage ${MCHOST} rdp purge ${MCHOST}
				#add hosts/studio/atelier
				for THISCONTAINER in ${THESECONTAINERS}
				do		
					THISCONTAINERIP=$(get_container_ip ${THISCONTAINER})
					mcmanage ${MCHOST} hosts add ${THISCONTAINER} ${THISCONTAINERIP}
					[[ "$STUDIO" == "true" && "$(isHS ${THISCONTAINER})" == "true" ]] && mcmanage ${MCHOST} studio add ${THISCONTAINER}
					[[ "$ATELIER" == "true" && "$(isHS ${THISCONTAINER})" == "true" ]] && mcmanage ${MCHOST} atelier add ${THISCONTAINER}
					[[ "$(isRDP ${THISCONTAINER})" == "true" ]] && mcmanage ${MCHOST} rdp add ${THISCONTAINER}
				done
				#hosts_add_nginx $TYPE
			else
				log "${MCHOST} marked as integrated but offline"
			fi
		fi
	done 3<${SYSTEMPATH}/management_clients
else
	#nothing is up so puge hosts

	delete_global MCS
	while read -u 3 MCHOST USERNAME TYPE INTEGRATE STUDIO ATELIER
	do
		if [[ "${INTEGRATE}" == "true" ]]
		then
			if [[ "$(client_status ${MCHOST})" == "online" ]]
			then
				#update routing                          
                                mcmanage ${MCHOST} route remove
				#purge hosts
				mcmanage ${MCHOST} hosts purge
				#purge registry/atelier
				[[ "$STUDIO" == "true" ]] && mcmanage ${MCHOST} studio purge
				[[ "$ATELIER" == "true" ]] && mcmanage ${MCHOST} studio purge
				[[ "$STUDIO" == "true" ]] && mcmanage ${MCHOST} studio purge rdp 
			fi
		fi
	done 3<${SYSTEMPATH}/management_clients
fi			
