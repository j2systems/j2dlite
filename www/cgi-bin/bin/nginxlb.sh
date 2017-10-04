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

#source $THISPATH/source/functions.sh
#[[ -f $THISPATH/tmp/j2nginx.conf ]] && rm -f $THISPATH/tmp/j2nginx.conf

#while read NGINXTO URL PORTFROM PORTTO
#do
#	add_nginx_entry $NGINXTO $URL $PORTFROM $PORTTO
#done < $THISPATH/tmp/nginx
#chmod 777 ${THISPATH}/tmp/j2nginx.conf

NGINXLBCONF=/var/www/cgi-bin/tmp/j2nginxlb.conf
[[ -f ${NGINXLBCONF} ]] && rm -f ${NGINXLBCONF}
while read URL LBNAME ALGORITHM HOSTS
do
	ACTUALURL=$(echo ${URL}|cut -d ":" -f1)
	URLPORT=$(echo ${URL}|cut -d ":" -f2)
	echo -e "\tupstream ${LBNAME} {" >> ${NGINXLBCONF}
	echo -e "\t\t${ALGORITHM};" >> ${NGINXLBCONF}
	for DESTINATION in ${HOSTS}
	do
		THISSERVER=$(echo ${DESTINATION}|cut -d ":" -f1)
		THISPORT=$(echo ${DESTINATION}|cut -d ":" -f2)
		THISBACKUP=$(echo ${DESTINATION}|cut -d ":" -f3)
		THISWEIGHT=$(echo ${DESTINATION}|cut -d ":" -f4)
		[[ "$THISWEIGHT" != "" ]] && THISWEIGHT=" weight=${THISWEIGHT}"
		echo -e "\t\tserver ${THISSERVER}:${THISPORT}${THISWEIGHT};" >> ${NGINXLBCONF}
	done
	echo -e "\t}" >> ${NGINXLBCONF}
	echo -e "\tserver {" >> ${NGINXLBCONF}
	echo -e "\t\tlisten ${URLPORT};" >> ${NGINXLBCONF}
	echo -e "\t\tserver_name ${ACTUALURL};" >> ${NGINXLBCONF}
	echo -e "\t\tlocation / {"  >> ${NGINXLBCONF}
	echo -e "\t\t\tproxy_pass http://${LBNAME};" >> ${NGINXLBCONF}
	echo -e "\t\t}" >> ${NGINXLBCONF}
	echo -e "\t}" >> ${NGINXLBCONF}

done < $THISPATH/tmp/nginxlb	

chmod 777 ${THISPATH}/tmp/j2nginxlb.conf
docker cp ${THISPATH}/tmp/j2nginxlb.conf nginx:/etc/nginx/conf.d/j2nginxlb.conf
docker exec -t nginx sh -c "service nginx stop"
docker exec -t nginx nginx &
docker exec -t nginx sh -c "service nginx reload"
. ${THISPATH}/bin/mclientupdate.sh

