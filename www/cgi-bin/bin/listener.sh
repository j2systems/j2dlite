#!/bin/bash
#
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
echo ${REMOTE_ADDR} > /tmp/bob
log "listener activated"

while :
do
	unset COMMAND
	unset DOTHIS
	read DOTHIS
	. ${TMPPATH}/globals
	log "RUN ${DOTHIS}"
	ACTION=$(echo $DOTHIS|cut -d "=" -f1)
	CONTAINER=$(echo $DOTHIS|cut -d "=" -f2-)		
	case $ACTION in
		"restart")
			reboot
			;;
		"shutdown")
			poweroff
			;;
		"containerstatus")
			bash ${BINPATH}/container-status.sh
			;;
		"containerinfo")
			bash ${BINPATH}/container-status.sh ${CONTAINER}
			;;
		"console")
			kill -9 $(pgrep -o shellinaboxd)
			if [[ "$CONTAINER" != "J2DOCKERROOT" ]]
			then
				shellinaboxd -t --port 4202 -s ":tc::/tmp:sh -c \"/sbin/docker exec -it $CONTAINER /bin/sh\"" &
				echo ""
				echo "CONSOLE,${REMOTE_ADDR},${CONTAINER},on,http://${HOSTIP}:4202"
			else
				shellinaboxd -t --port 4202 -s ":root::/tmp:/bin/sh" &
				echo "http://${HOSTIP}:4202"
			fi
			;;
		"noconsole")
			kill -9 $(pgrep -o shellinaboxd)
			docker exec $CONTAINER bash -c "for PS in $(pgrep -t pts/0); do kill -9 ${PS};done"
			echo "CONSOLE,${REMOTE_ADDR},${CONTAINER},off"
			;;
		"systemstatus")
			bash ${BINPATH}/job-status.sh
			;;
		"save")
			SAVECONTAINER=$CONTAINER
			write_global SAVECONTAINER
			;;
		start|stop|delete|commit|export)
			FILENAME="$(date +"%Y%m%d%H%M%S")$((RANDOM))"
			echo "${REMOTE_ADDR},docker ${ACTION} ${CONTAINER}" > ${JOBREQUESTPATH}/${FILENAME}
			;;	
		"post")
			RTNCONTAINER=$CONTAINER
			write_global RTNCONTAINER
			;;
		"checkclient")
			bash ${BINPATH}/mclientcheck.sh ${CONTAINER}
			;;
		"rejectclient")
			echo ${CONTAINER} >> ${SYSTEMPATH}/management_clients_declined
			echo "true"
			;;
		"acceptclient")
			echo
			;;

		"interact")
			log "interact ${CONTAINER}"
			EXECSCRIPT=$(echo ${CONTAINER}|cut -d "," -f1)
			EXECPARAM=$(echo ${CONTAINER}|cut -d "," -f2-)
			log "${BINPATH}/${EXECSCRIPT},${EXECPARAM}"
			bash ${BINPATH}/${EXECSCRIPT} "${EXECPARAM}" 
			;;
		*)
			log "RESEND $DOTHIS"
			echo "RESEND $DOTHIS"
			;;
	esac
done
