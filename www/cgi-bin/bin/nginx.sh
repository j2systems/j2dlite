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
source $THISPATH/source/functions.sh
[[ -f $THISPATH/tmp/j2nginx.conf ]] && rm -f $THISPATH/tmp/j2nginx.conf

while read NGINXTO URL PORTFROM PORTTO
do
	add_nginx_entry $NGINXTO $URL $PORTFROM $PORTTO
done < $THISPATH/tmp/nginx
chmod 777 ${THISPATH}/tmp/j2nginx.conf
docker cp ${THISPATH}/tmp/j2nginx.conf nginx:/etc/nginx/conf.d/j2nginx.conf
docker exec -t nginx sh -c "service nginx reload"
. ${THISPATH}/bin/mclientupdate.sh



