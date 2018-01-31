#!/bin/bash
#
# Script to add rsa pub key to client and update tmp/management-clients
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

echo $1
MCUSERNAME=$(echo $1|cut -d "," -f1)
THISPASSWORD=$(echo $1|cut -d "," -f2)
MCPASSWORD=$(decodeURL ${THISPASSWORD})
MCHOSTTYPE=$(echo $1|cut -d "," -f3)
MCHOSTIP=$(echo $1|cut -d "," -f4)
MCSTUDIO=$(echo $1|cut -d "," -f5)
MCATELIER=$(echo $1|cut -d "," -f6)
echo "Add integrated client."
echo "This will add an RSA certificate to the \"authorized_keys\" file"
echo "in the users .ssh directory on ${MCHOSTIP}."
echo 
if [[ "$(sshpass -p ${MCPASSWORD} ssh -o StrictHostKeyChecking=no ${MCUSERNAME}@${MCHOSTIP} echo ok)" == "ok" ]]
then
	if [[ "$(sshpass -p ${MCPASSWORD} ssh -o StrictHostKeyChecking=no ${MCUSERNAME}@${MCHOSTIP} ls .ssh)" == "" ]]
	then
		sshpass -p ${MCPASSWORD} ssh -o StrictHostKeyChecking=no ${MCUSERNAME}@${MCHOSTIP} mkdir .ssh
		sshpass -p ${MCPASSWORD} ssh -o StrictHostKeyChecking=no ${MCUSERNAME}@${MCHOSTIP} chmod 700 .ssh
	else
		sshpass -p ${MCPASSWORD} rsync ${MCUSERNAME}@${MCHOSTIP}:.ssh/authorized_keys /tmp/authorized_keys
	fi 
	cat /root/.ssh/id_rsa.pub >> /tmp/authorized_keys
	echo "Transferring authorized keys back to client."
	sshpass -p ${MCPASSWORD} rsync /tmp/authorized_keys ${MCUSERNAME}@${MCHOSTIP}:.ssh/authorized_keys 
	echo "Keys in place.  Testing logon."
	NEWHOSTNAME=$(ssh ${MCUSERNAME}@${MCHOSTIP} hostname | dos2unix)
	NEWHOSTNAME=$(echo "${NEWHOSTNAME}"|cut -d "." -f1)
	if [[ "${NEWHOSTNAME}" == "" ]]
	then
		echo "Transfer failed."
	else
		echo "Success."
		echo "Adding ${MCHOSTIP} to integrated clients list."
		sed  -i "/${NEWHOSTNAME}/d" ${SYSTEMPATH}/wsdetail_MClients 
		add_host ${MCHOSTIP} ${NEWHOSTNAME}
		ssh -o StrictHostKeyChecking=no ${MCUSERNAME}@${NEWHOSTNAME} hostname
		echo "${NEWHOSTNAME},${MCUSERNAME},${MCHOSTTYPE},true,${MCSTUDIO},${MCATELIER}" >> ${SYSTEMPATH}/wsdetail_MClients
		if [[ "${MCHOSTTYPE}" == "WINDOWS" ]]
		then
			echo "Transferring management script"
			rsync ${BINPATH}/clients/* ${MCUSERNAME}@${NEWHOSTNAME}:
		fi
		echo "Adding hosts entry"
		mcmanage ${NEWHOSTNAME} hosts add ${HOSTNAME} ${HOSTIP}
		rm -rf /tmp/authorized_keys
		echo "done."
	fi
else
	echo "Logon failed.  Perhaps wrong username and\or password"
fi

echo "SCRIPT END"
rm -rf tmp/authorized_keys
