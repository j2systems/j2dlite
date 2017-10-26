#!/bin/bash
#
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
log "listener activated."

while :
do
	unset COMMAND
	unset DOTHIS
	read DOTHIS
	. ${TMPPATH}/globals
	log "RUN ${DOTHIS}"
	ACTION=$(echo $DOTHIS|cut -d "=" -f1)
	# DETAIL may be a container name or information request, e.g. submenus,vpn details etc.
	DETAIL=$(echo $DOTHIS|cut -d "=" -f2-)		
	case $ACTION in
		"advancedbuttons")
			bash ${BINPATH}/wsinfo-sysoptions.sh
			;;
		"submenu")
			bash ${BINPATH}/wsinfo-sysoptions.sh "${DETAIL}"
			;;
		"vpndetails")
			bash ${BINPATH}/wsinfo-vpn.sh
			;;
		"doAction")
			case $DETAIL in
				"Restart")
					reboot
					;;
				"SHUTDOWN")
					docker stop $(docker ps -q)
					${BINPATH}/mclientupdate.sh
					poweroff
					;;
				*)
					[[ -f ${BINPATH}/wsdetail-${DETAIL}.sh ]] && bash ${BINPATH}/wsdetail-${DETAIL}.sh
					;;
			esac
			;;
		"containerstatus")
			bash ${BINPATH}/container-status.sh
			;;
		"containerinfo")
			bash ${BINPATH}/container-status.sh ${DETAIL}
			;;
		"console")
			kill -9 $(pgrep -o shellinaboxd)
			if [[ "$DETAIL" != "J2DOCKERROOT" ]]
			then
				shellinaboxd -t --port 4202 -s ":tc::/tmp:sh -c \"/sbin/docker exec -it $DETAIL /bin/sh\"" &
				echo ""
				echo "CONSOLE,${REMOTE_ADDR},${DETAIL},on,http://${HOSTIP}:4202"
			else
				shellinaboxd -t --port 4202 -s ":root::/tmp:/bin/sh" &
				echo "http://${HOSTIP}:4202"
			fi
			;;
		"noconsole")
			kill -9 $(pgrep -o shellinaboxd)
			docker exec $DETAIL bash -c "for PS in $(pgrep -t pts/0); do kill -9 ${PS};done"
			echo "CONSOLE,${REMOTE_ADDR},${DETAIL},off"
			;;
		"systemstatus")
			bash ${BINPATH}/job-status.sh
			;;
		"SysReq")
			CHANGE=$(echo ${DETAIL}|cut -d ":" -f1)
			INFO=$(echo ${DETAIL}|cut -d ":" -f2-)
			COMMAND=$(echo ${CHANGE}|cut -d "," -f1)
			CONTEXT=$(echo ${CHANGE}|cut -d "," -f2)
			DATAROW=$(echo ${CHANGE}|cut -d "," -f3)
			case ${COMMAND} in 
				Add)
					log "SysReq Add ${CONTEXT} ${DATAROW} ${INFO}"
					echo "${INFO}" >> ${SYSTEMPATH}/wsdetail_${CONTEXT}
					sort -n ${SYSTEMPATH}/wsdetail_${CONTEXT} -o ${SYSTEMPATH}/wsdetail_${CONTEXT}
					bash ${BINPATH}/wsdetail-${CONTEXT}.sh
					;;
				Amend)
					log "SysReq Amend ${CONTEXT} ${DATAROW} ${INFO}"
					sed -i "${DATAROW}s#.*#${INFO}#" ${SYSTEMPATH}/wsdetail_${CONTEXT}
					sort -n ${SYSTEMPATH}/wsdetail_${CONTEXT} -o ${SYSTEMPATH}/wsdetail_${CONTEXT}
					bash ${BINPATH}/wsdetail-${CONTEXT}.sh
					;;
				Remove)
					log "SysReq Remove ${CONTEXT} ${DATAROW} ${INFO}"
					sed -i "${DATAROW}d" ${SYSTEMPATH}/wsdetail_${CONTEXT}
					bash ${BINPATH}/wsdetail-${CONTEXT}.sh
					;;
				Connect)
					log "SysReq Connect ${CONTEXT} ${DATAROW} ${INFO}"
					;;
				*)
					log "SysReq No handler - ${COMMAND}"
					;;
			esac
			;;
		"save")
			SAVEDETAIL=$DETAIL
			write_global SAVEDETAIL
			;;
		start|stop|delete|commit|export)
			FILENAME="$(date +"%Y%m%d%H%M%S")$((RANDOM))"
			echo "${REMOTE_ADDR},docker ${ACTION} ${DETAIL}" > ${JOBREQUESTPATH}/${FILENAME}
			;;	
		"post")
			RTNDETAIL=$DETAIL
			write_global RTNDETAIL
			;;
		"checkclient")
			bash ${BINPATH}/mclientcheck.sh ${DETAIL}
			;;
		"rejectclient")
			echo ${DETAIL} >> ${SYSTEMPATH}/wsdetail_MClients_declined
			echo "true"
			;;
		"acceptclient")
			echo
			;;

		"interact")
			log "interact ${DETAIL}"
			EXECSCRIPT=$(echo ${DETAIL}|cut -d "," -f1)
			EXECPARAM=$(echo ${DETAIL}|cut -d "," -f2-)
			log "${BINPATH}/${EXECSCRIPT},${EXECPARAM}"
			bash ${BINPATH}/${EXECSCRIPT} "${EXECPARAM}" 
			;;
		*)
			log "RESEND $DOTHIS"
			echo "RESEND $DOTHIS"
			;;
	esac
done
