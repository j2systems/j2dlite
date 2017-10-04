#!/bin/bash
#
# All-in-one script to update management clients.
# Called at boot and when summary and system pages are opened

SCRIPTBASE=/var/www/cgi-bin
SOMETHINGTODO=false
source $SCRIPTBASE/source/functions.sh

while  read HOST USERNAME TYPE INTEGRATE STUDIO ATELIER
do
	if [[ "${INTEGRATE}" == "true" ]]
	then
		if [[ "$(client_status $HOST)" == "online" ]]
		then
			case $TYPE in
			"WINDOWS")
				[[ -f $SCRIPTBASE/tmp/windowshost ]] && rm -rf $SCRIPTBASE/tmp/windowshost
				#purge hosts
				hosts_purge_win $USERNAME $HOST
				#purge registry/atelier
				[[ "$STUDIO" == "true" ]] && purge_registry $USERNAME $HOST
				purge_rdp $USERNAME $HOST

				;;

			"LINUX")
				#purge hosts
				purge_hosts_linux $USERNAME $HOST
				#purge atelier
				#add hosts/studio/atelier
				#[[ "$ATELIER" == "true" ]] && purge_atelier $HOST $UNAME $THISCONTAINER
				;;
			esac
		fi
	fi
done < ${SYSTEMPATH}/management_clients			
