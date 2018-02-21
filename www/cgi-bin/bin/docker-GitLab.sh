#!/bin/bash
#
# Creates list of images on docker hub
. /var/www/cgi-bin/tmp/globals
THISTOKEN=""
THISIFS=$IFS
IFS=","
[[ -f ${TMPPATH}/dockergitlab ]] && rm -rf ${TMPPATH}/dockergitlab
while read -u 3 USERNAME PASSWORD TOKEN ID GROUP REPO BRANCH BRANCHUSER BRANCHDATE
do
	if [[ "${REPO}" != "done" ]]
	then
		if [[ "${USERNAME}" != "" ]]
		then
			GROUPLC=$(echo ${GROUP}|tr A-Z a-z)
			REPOLC=$(echo ${REPO}|tr A-Z a-z)
			echo "Checking ${GROUPLC}/${REPOLC}"
			unset THISTOKEN
			THISTOKEN=$(curl -k -s --user "${USERNAME}:${PASSWORD}" "https://gitlab.j2interactive.com/jwt/auth?client_id=docker&offline_token=true&service=container_registry&scope=repository:${GROUPLC}/${REPOLC}:push,pull"|jq -r .token)	
			IMAGELIST=$(curl -s -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' -H "Authorization: Bearer ${THISTOKEN}" https://gitlab.j2interactive.com:5002/v2/${GROUPLC}/${REPOLC}/tags/list -k)
			if [[ $(echo ${IMAGELIST}|grep -c "tags") -gt 0 ]]
			then
				for IMAGE in $(echo ${IMAGELIST}|cut -d " " -f2|cut -d ":" -f2|tr -d "{[]}\"")
				do
					echo "gitlab.j2interactive.com:5002/${GROUPLC}/${REPOLC} ${IMAGE}" >> ${TMPPATH}/dockergitlab
				done
			fi
		fi
	fi
done 3<${SYSTEMPATH}/wsdetail_GitLab
IFS=${THISIFS}
