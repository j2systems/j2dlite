#!/bin/bash
#
# Remove mc entries and power off              
#
. /var/www/cgi-bin/tmp/globals
SCRIPTBASE=/var/www/cgi-bin
SOMETHINGTODO=false
source ${SOURCEPATH}/functions.sh
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
			[[ "$ATELIER" == "true" ]] && mcmanage ${MCHOST} atelier purge
			mcmanage ${MCHOST} rdp purge  
		fi
	fi
done 3<${SYSTEMPATH}/management_clients
log "Issue poweroff"
poweroff

