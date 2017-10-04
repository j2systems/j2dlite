#!/bin/bash
#
# Script to check requesting client for integration
# 1. Checks /etc/hosts.
# 2. Checks config/management_clients_declined
# 3. If not in management_clients_declined, tries an ssh for hostname
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
for REFERENCE in management_clients management_clients_declined
do
	if [[ ! -f ${SYSTEMPATH}/${REFERENCE} ]]
	then
		echo ${SYSTEMPATH}/${REFERENCE}
		touch ${SYSTEMPATH}/${REFERENCE}
		chmod 666 ${SYSTEMPATH}/${REFERENCE}
	fi
done
# check /etc/hosts
if [[ $(grep -c -e "^${CHECKHOSTIP} " /etc/hosts) -eq 0 ]]
then
	# check "declined" ip list
	if [[ $(grep -c -e "${CHECKHOSTIP}$" ${SYSTEMPATH}/management_clients_declined) -eq 0 ]]
	then
		# try ssh to management_clients list
		KNOWNHOST=false                                   
		while read HOST USERNAME TYPE STUDIO ATELIER                       
		do      
			if [[ "${KNOWNHOST}" == "false" ]]                              
			then                                                            
				RHOSTNAME=$(ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey ${USERNAME}@${CHECKHOSTIP} hostname 2>/dev/null|dos2unix)
				if [[ "${RHOSTNAME}" != "" ]]                            
				then    
					KNOWNHOST=true                                  
					add_host ${CHECKHOSTIP} ${RHOSTNAME}
					ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey ${USERNAME}@${RHOSTNAME} hostname 2>/dev/null
					mcmanage ${RHOSTNAME} hosts add ${HOSTNAME} ${HOSTIP}
				fi                                                      
			fi                                                              
		done < <(cat ${SYSTEMPATH}/management_clients)                          
		echo ${KNOWNHOST}
	else
		echo "true"
	fi
else
	echo "true"
fi
