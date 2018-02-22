#!/bin/bash
#
# Updates docker nginx reverse proxy
# add containers to j2nginx.conf
# upload this to the nginx container - /etc/nginx/conf.d
# 
# re-write j2nginx.conf
# copy to nginx
# Reload nginx
# Update hosts.

THISPATH=/var/www/cgi-bin
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
NGINXLBCONF=${TMPPATH}/j2nginxlb.conf
#[[ -f ${NGINXLBCONF} ]] && rm -f ${NGINXLBCONF}
#[[ -f ${TMPPATH}/j2nginx.conf ]] && rm -f ${TMPPATH}/j2nginx.conf
echo "http {" > ${NGINXLBCONF}
THISIFS=$IFS
IFS=","
CURRENTURL=""
while read TARGETURL TARGETPORT LBNAME ALGORITHM LBTARGET LBPORT LBWEIGHT
do
	#if read target url does not match current url
	#if current url blank, start a new entry else finish existing and start new

	if [[ "${TARGETURL}" != "${CURRENTURL}" ]]
	then
		if [[ "${CURRENTURL}" != "" ]]
		then
			#there's been a change in target url so close this nginx entry and start new
			echo "Close entry"
			echo -e "\t}" >> ${NGINXLBCONF}                                                         
			echo -e "\tserver {" >> ${NGINXLBCONF}                                                  
			echo -e "\t\tlisten ${CURRENTTPORT};" >> ${NGINXLBCONF}                                   
			echo -e "\t\tserver_name ${CURRENTURL};" >> ${NGINXLBCONF}                               
			echo -e "\t\tlocation / {"  >> ${NGINXLBCONF}                                           
			echo -e "\t\t\tproxy_pass http://${CURRENTLBNAME};" >> ${NGINXLBCONF}                          
			echo -e "\t\t}" >> ${NGINXLBCONF}                                                       
			echo -e "\t}" >> ${NGINXLBCONF}
		fi
		echo "New Rule"
		echo -e "\tupstream ${LBNAME} {" >> ${NGINXLBCONF}
		echo -e "\t\t${ALGORITHM};" >> ${NGINXLBCONF}
		echo -e "\t\tserver ${LBTARGET}:${LBPORT} weight=${LBWEIGHT};" >> ${NGINXLBCONF}
		CURRENTURL=${TARGETURL}
		CURRENTPORT=${TARGETPORT}
		CURRENTLBNAME=${LBNAME}
		write_global CURRENTURL
	else
		echo "append target"
		#write_global TARGETURL
		#write_global TARGETPORT
		#write_global LBNAME
		#write the entry for the target server
		echo -e "\t\tserver ${LBTARGET}:${LBPORT} weight=${LBWEIGHT};" >> ${NGINXLBCONF}
	fi
	write_global TARGETURL
	write_global TARGETPORT
	write_global LBNAME
done < ${SYSTEMPATH}/wsdetail_LoadBalance

#if something was written, close it


	. ${TMPPATH}/globals
	
	echo -e "\t}" >> ${NGINXLBCONF}
	echo -e "\tserver {" >> ${NGINXLBCONF}
	echo -e "\t\tlisten ${TARGETPORT};" >> ${NGINXLBCONF}
	echo -e "\t\tserver_name ${TARGETURL};" >> ${NGINXLBCONF}
	echo -e "\t\tlocation / {"  >> ${NGINXLBCONF}
	echo -e "\t\t\tproxy_pass http://${LBNAME};" >> ${NGINXLBCONF}
	echo -e "\t\t}" >> ${NGINXLBCONF}
	echo -e "\t}\n}" >> ${NGINXLBCONF}
	delete_global TARGETURL
	delete_global TARGETPORT
	delete_global LBNAME

if [[ "$(get_container_ip nginx)" != "" ]]
then
	chmod 777 ${THISPATH}/tmp/j2nginxlb.conf
	docker cp ${THISPATH}/tmp/j2nginxlb.conf nginx:/etc/nginx/conf.d/j2nginxlb.conf
	docker exec -t nginx sh -c "service nginx stop"
	docker exec -t nginx nginx &
	docker exec -t nginx sh -c "service nginx reload"
fi

