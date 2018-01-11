#!/bin/bash
#
# Script to check requesting client for integration
# 1. Checks /etc/hosts.
# 2. Checks system/wsdetail_MClients_declined
# 3. If not in wsdetail_MClients_declined, tries an ssh for hostname
# 4. If hostname present, ssh successful therefore previously managed, 
#	ip/hostname added to /etc/hosts, true sent to websocket.
# 5. false sent to websocket, creating "Add....." option at top of page
# 
# $1 is the IP supplied (and hidden) on the page from env REMOTE_ADDR

CHECKHOSTIP=$1
KNOWNHOSTS=/etc/hosts
. /var/www/cgi-bin/tmp/globals
source ${WWWROOT}/source/functions.sh
cd ${WWWROOT}
# check hostname
for REFERENCE in wsdetail_MClients wsdetail_MClients_declined
do
	if [[ ! -f ${SYSTEMPATH}/${REFERENCE} ]]
	then
		echo ${SYSTEMPATH}/${REFERENCE}
		touch ${SYSTEMPATH}/${REFERENCE}
		chmod 666 ${SYSTEMPATH}/${REFERENCE}
	fi
done
THISIFS=$IFS
IFS=","

# check /etc/hosts
if [[ $(grep -c -e "^${CHECKHOSTIP} " /etc/hosts) -eq 0 ]]
then
	# check "declined" ip list
	if [[ $(grep -c -e "${CHECKHOSTIP}$" ${SYSTEMPATH}/wsdetail_MClients_declined) -eq 0 ]]
	then
		# try ssh to wsdetail_MClients list
		KNOWNHOST=false                                   
		while read -u3 HOST USERNAME TYPE STUDIO ATELIER                       
		do 
			if [[ "${KNOWNHOST}" == "false" ]]                              
			then
				if [[ "${TYPE}" == "${MANHOSTTYPE}" ]]
				then
 					RHOSTNAME=$(ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey ${USERNAME}@${CHECKHOSTIP} hostname 2>/dev/null|dos2unix)
					RHOSTNAME=$(echo "${RHOSTNAME}"|cut -d "." -f1)
					if [[ "${RHOSTNAME}" != "" ]]                            
					then    
						KNOWNHOST=true                                  
						add_host ${CHECKHOSTIP} ${RHOSTNAME}
						ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey ${USERNAME}@${RHOSTNAME} hostname 2>/dev/null
						mcmanage ${RHOSTNAME} hosts add ${HOSTNAME} ${HOSTIP}
					fi
				fi                                                      
			fi                                                              
		done 3<${SYSTEMPATH}/wsdetail_MClients                         
		echo "mclient=${KNOWNHOST}"
		log "client checked and returned  ${KNOWNHOST}" 
	else
		echo "mclient=true"
		log "client listed in ${SYSTEMPATH}/wsdetail_MClients_declined"
	fi
else
	log "client listed in /etc/hosts"
	echo "mclient=true"
fi
IFS=$THISIFS
#bash ${BINPATH}/dockerhub.sh
