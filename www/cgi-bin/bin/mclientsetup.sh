#!/bin/bash
#
# Script to add rsa pub key to client and update tmp/management-clients
ROOTPATH=/var/www/cgi-bin
cd $ROOTPATH
source source/functions.sh
. tmp/globals
# open_terminal
echo "Add integrated client."
echo "This will add an RSA certificate to the \"authorized_keys\" file"
echo "in the users .ssh directory on ${HOSTIP}."
echo 
if [[ "$(sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no ${USERNAME}@${HOSTIP} echo ok)" == "ok" ]]
then
	if [[ "$(sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no ${USERNAME}@${HOSTIP} ls .ssh)" == "" ]]
	then
		sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no ${USERNAME}@${HOSTIP} mkdir .ssh
		sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no ${USERNAME}@${HOSTIP} chmod 700 .ssh
	else
		sshpass -p ${PASSWORD} rsync ${USERNAME}@${HOSTIP}:.ssh/authorized_keys tmp/authorized_keys
	fi 
	cat /root/.ssh/id_rsa.pub >> tmp/authorized_keys
	echo "Transferring authorized keys back to client."
	sshpass -p ${PASSWORD} rsync tmp/authorized_keys ${USERNAME}@${HOSTIP}:.ssh/authorized_keys 
	echo "Keys in place.  Testing logon."
	NEWHOSTNAME=$(ssh ${USERNAME}@${HOSTIP} hostname | dos2unix)
	if [[ "${NEWHOSTNAME}" == "" ]]
	then
		echo "Transfer failed."
	else
		echo "Success."
		echo "Adding ${HOSTIP} to integrated clients list."
		sed  -i "/${NEWHOSTNAME}/d" ${SYSTEMPATH}/management_clients 
		add_host ${HOSTIP} ${NEWHOSTNAME}
		ssh -o StrictHostKeyChecking=no ${USERNAME}@${NEWHOSTNAME} hostname
		echo "${NEWHOSTNAME} ${USERNAME} ${MANHOSTTYPE} true ${STUDIO} ${ATELIER}" >> ${SYSTEMPATH}/management_clients
		echo "Transferring management files"
		rsync bin/clients/* ${USERNAME}@${NEWHOSTNAME}:
		echo "Adding hosts entry"
		hosts_add_win ${USERNAME} ${NEWHOSTNAME} ${HOSTIP} $(hostname)
		rm -rf tmp/authorized_keys
#		echo -n "Saving new ssh config..."
#		filetool.sh -b 2>&1 >/dev/null
		echo "done."
	fi
else
	echo "Logon failed.  Perhaps wrong username and\or password"
fi

echo "SCRIPT END"
rm -rf tmp/authorized_keys
delete_global USERNAME
delete_global PASSWORD
delete_global STUDIO
delete_global ATELIER
