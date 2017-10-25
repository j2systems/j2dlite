#!/bin/bash
source source/functions.sh
. tmp/globals
MANHOSTIP=$(env|grep "REMOTE_ADDR"|cut -d "=" -f2)
if [[ $(echo $HTTP_USER_AGENT|grep -c "Windows") -eq 1 ]]
then
        MANHOSTTYPE=WINDOWS
elif [[ $(echo $HTTP_USER_AGENT|grep -c "Macintosh") -eq 1 ]]
then
        MANHOSTTYPE=MAC
elif [[ $(echo $HTTP_USER_AGENT|grep -c "Linux") -eq 1 ]]
then
        MANHOSTTYPE=LINUX
else
        MANHOSTTYPE=OTHER
fi
write_global MANHOSTTYPE
write_global MANHOSTIP
cat base/header 
cat base/nav|sed "s/screen4/green/g"
cat base/advanced
echo "<input type=\"hidden\" id=\"IP\" value=\"${MANHOSTIP}\">"
if [[ "$REQUEST_METHOD" == "POST" ]]
then
	read INFO
	THISHOST=$(echo ${INFO}|cut -d "&" -f1|cut -d "=" -f2)
	THISCHANGE=$(echo ${INFO}|cut -d "&" -f2|cut -d "=" -f1)
	THISVALUE=$(echo ${INFO}|cut -d "&" -f2|cut -d "=" -f2)
	CURRENTENTRY=$(cat system/management_clients|grep -e "^${THISHOST}")
	if [[ "${CURRENTENTRY}" != "" ]]
	then
		case ${THISCHANGE} in
			"Delete")
				sed -i "/${THISHOST}/d" system/management_clients
				;;
			*)
				THISUSER=$(echo ${CURRENTENTRY}|cut -d " " -f2)
				THISTYPE=$(echo ${CURRENTENTRY}|cut -d " " -f3)
				THISINTEGRATE=$(echo ${CURRENTENTRY}|cut -d " " -f4)
				THISSTUDIO=$(echo ${CURRENTENTRY}|cut -d " " -f5)
				THISATELIER=$(echo ${CURRENTENTRY}|cut -d " " -f6)
				[[ ${THISVALUE} == "true" ]] && NEWVALUE="false"||NEWVALUE="true"
				sed -i "/${THISHOST}/d" system/management_clients
				case ${THISCHANGE} in
				"INTEGRATED")
					[[ "${NEWVALUE}" == "false" ]] && THISSTUDIO="false" && THISATELIER="false"
					echo ${THISHOST} ${THISUSER} ${THISTYPE} ${NEWVALUE} ${THISSTUDIO} ${THISATELIER} >> system/management_clients
					;;
				"STUDIO")
					echo ${THISHOST} ${THISUSER} ${THISTYPE} ${THISINTEGRATE} ${NEWVALUE} ${THISATELIER} >> system/management_clients
					;;
				"ATELIER")
					echo ${THISHOST} ${THISUSER} ${THISTYPE} ${THISINTEGRATE} ${THISSTUDIO} ${NEWVALUE} >> system/management_clients
					;;
				esac
				sort system/management_clients -o system/management_clients
				;;
		esac
	fi
fi
cat base/footer

