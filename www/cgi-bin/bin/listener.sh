#!/bin/bash
#
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
log "listener activated."

while :
do
	unset COMMAND
	unset DOTHIS
	until [[ ${DOTHIS} != "" ]]
	do 
		read DOTHIS
	done
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
		"getDetail")
			[[ -f ${BINPATH}/wsdetail-${DETAIL}.sh ]] && bash ${BINPATH}/wsdetail-${DETAIL}.sh
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
				Add|New)
					echo "${INFO}" >> ${SYSTEMPATH}/wsdetail_${CONTEXT}
					sort -n ${SYSTEMPATH}/wsdetail_${CONTEXT} -o ${SYSTEMPATH}/wsdetail_${CONTEXT}
					bash ${BINPATH}/wsdetail-${CONTEXT}.sh
					;;
				Amend)
					if [[ $(sed -n ${DATAROW}p ${SYSTEMPATH}/wsdetail_${CONTEXT}) == "" ]]
					then
						echo ${INFO} >> ${SYSTEMPATH}/wsdetail_${CONTEXT}
					else
						sed -i "${DATAROW}s#.*#${INFO}#" ${SYSTEMPATH}/wsdetail_${CONTEXT}
					fi
					#sort -n ${SYSTEMPATH}/wsdetail_${CONTEXT} -o ${SYSTEMPATH}/wsdetail_${CONTEXT}
					bash ${BINPATH}/wsdetail-${CONTEXT}.sh
					;;
				Remove)
					sed -i "${DATAROW}d" ${SYSTEMPATH}/wsdetail_${CONTEXT}
					bash ${BINPATH}/wsdetail-${CONTEXT}.sh
					;;
				Connect)
					log "SysReq Connect ${CONTEXT} ${DATAROW} ${INFO}"
					;;
				Clone)
					log "SysReq Clone ${CONTEXT} -${DATAROW}-${INFO}"
					# git clone
					bash ${BINPATH}/wsdetail-wait.sh
					bash ${BINPATH}/git-clone.sh $(echo ${INFO}|tr "," " ") 

					bash ${BINPATH}/wsdetail-${CONTEXT}.sh
					;;
				Refresh)
					log "SysReq Refresh ${CONTEXT} -${DATAROW}-${INFO}"
					bash ${BINPATH}/git-refresh.sh $(echo ${INFO}|tr "," " ")
					bash ${BINPATH}/wsdetail-${CONTEXT}.sh
					;;
				Unclone)
					log "SysReq Unclone ${CONTEXT} -${DATAROW}-${INFO}"
					bash ${BINPATH}/git-unclone.sh $(echo ${INFO}|tr "," " ")
					bash ${BINPATH}/wsdetail-${CONTEXT}.sh
					;;
				ReSync)
					echo ${INFO}|sed "s/done/none/g" > ${SYSTEMPATH}/wsdetail_${CONTEXT}
					bash ${BINPATH}/wsdetail-${CONTEXT}.sh
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
			RTNCONTAINER=$DETAIL
			write_global RTNCONTAINER
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
		"execscript")
			log "execscript ${DETAIL}"
			SCRIPTCONTAINER=${DETAIL}
			write_global SCRIPTCONTAINER
			#echo "URL,image-cacherun.cgi"
			;;
		*)
			log "Received $DOTHIS, #$ACTION#"
			#echo "RESEND $DOTHIS"
			;;
	esac
done
