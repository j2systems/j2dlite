#!/bin/bash
#
# Creates list of images on docker hub
. /var/www/cgi-bin/tmp/globals
[[ ! -f ${SYSTEMPATH}/wsdetail_DockerHub ]] && touch  ${SYSTEMPATH}/wsdetail_DockerHub

THISIFS=$IFS
IFS=","
while read REPO SUBREPO USERNAME PASSWORD
do
	IFS=$THISIFS
	if [[ "${USERNAME}" != "" ]]
	then
		TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${USERNAME}'", "password": "'${PASSWORD}'"}' https://hub.docker.com/v2/users/login/|jq -r .token)
		THISURL="https://hub.docker.com/v2/repositories/${REPO}/${SUBREPO}/tags/"
		while [[ "${THISURL}" != "null" ]]
		do
			NEWINFO=$(curl -s -H "Authorization: JWT ${TOKEN}" ${THISURL})
			echo ${NEWINFO}|jq -r '.results|.[]|"\(.name) \(.full_size) \(.last_updated)"'>>/var/www/cgi-bin/tmp/dockerhub
			THISURL=$(echo ${NEWINFO}|jq -r '.next')
		done
	fi
done < ${SYSTEMPATH}/wsdetail_DockerHub
IFS=$THISIFS
