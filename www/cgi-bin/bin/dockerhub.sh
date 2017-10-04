#!/bin/bash
#
# Creates list of images on docker hub
. /var/www/cgi-bin/tmp/globals
[[ -f /var/www/cgi-bin/tmp/dockerhub ]] && rm -f /var/www/cgi-bin/tmp/dockerhub && touch /var/www/cgi-bin/tmp/dockerhub && chmod 666 /var/www/cgi-bin/tmp/dockerhub 
#Put master list in tmp
if [[ "${J2USER}" != "" ]]
then
	TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${J2USER}'", "password": "'${J2PASS}'"}' https://hub.docker.com/v2/users/login/|jq -r .token)
	RECURSE=true
	THISURL=https://hub.docker.com/v2/repositories/j2systems/docker/tags/
	while [[ "${THISURL}" != "null" ]]
	do
		NEWINFO=$(curl -s -H "Authorization: JWT ${TOKEN}" ${THISURL})
		echo ${NEWINFO}|jq -r '.results|.[]|"\(.name) \(.full_size) \(.last_updated)"'>>/var/www/cgi-bin/tmp/dockerhub
		THISURL=$(echo ${NEWINFO}|jq -r '.next')
	done
fi


