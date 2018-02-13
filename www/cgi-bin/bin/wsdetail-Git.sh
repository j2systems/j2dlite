#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

echo "DETAIL,Git,REFRESH,Uri,Username,Password,Branch,Date,Author,Update:Add,Remove:"
echo "DETAIL,Git,FIELDS,INPUT,INPUT,PASSWORD,SELECT,TD,TD,BUTTON,BUTTON"
echo "DETAIL,Git,STYLES,label6 gray,gray,gray,gray,gray,gray,yellow:green,red:"

COMMONDIR=/var/lib/docker/volumes/common/_data
COUNT=1
THISIFS=$IFS
IFS=","
while read -u3 URL USERNAME PASSWORD CURRENTBRANCH CACHEDTIMESTAMP CACHEDUPDATER 
do
	# get branch list
	REPOMAIN=$(echo ${URL}|rev|cut -d "/" -f2|rev)
	REPOSUB=$(echo ${URL}|rev|cut -d "/" -f1|rev)
	CURRENTPWD=$(pwd) 
	if [[ ! -d ${COMMONDIR}/${REPOMAIN}.${REPOSUB} ]]
	then
		echo "DETAIL,Git,a,${URL},${USERNAME},${PASSWORD},${CURRENTBRANCH}:${CURRENTBRANCH},Cloning....,"
		log "$REPOMAIN $REPOSUB"
		mkdir ${COMMONDIR}/${REPOMAIN}.${REPOSUB}
		cd ${COMMONDIR}/${REPOMAIN}.${REPOSUB}
		git clone https://${USERNAME}:${PASSWORD}@${URL}
		bash ${BINPATH}/$(basename $0)
		exit	
	else
		cd ${COMMONDIR}/${REPOMAIN}.${REPOSUB}
	fi
	REPODIR=$(find . -maxdepth 2 -mindepth 2 -type d -name .git|rev|cut -d "/" -f2-|rev)
	if [[ "${REPODIR}" == "" ]]
	then
		echo "DETAIL,Git,${COUNT},${URL},${USERNAME},${PASSWORD},${CURRENTBRANCH}:${CURRENTBRANCH},Error.,No .git found"
	else	
		cd ${REPODIR}
		unset BRANCHLIST
		for BRANCH in $(git branch -a|grep remotes|cut -d "/" -f3|cut -d " " -f1|tr "\n" " ")
		do
			if [[ "${BRANCHLIST}" == "" ]]
			then
				BRANCHLIST=${BRANCH}
			else
				BRANCHLIST=$(echo "${BRANCHLIST} ${BRANCH}")
			fi
		done
		SETBRANCH=$(git branch -a|grep "*"|cut -d "*" -f2|tr -d " ")
		if [[ "${SETBRANCH}" != "${CURRENTBRANCH}" ]]
		then
			echo "DETAIL,Git,a,${URL},${USERNAME},${PASSWORD},${CURRENTBRANCH}:${CURRENTBRANCH},Checking....,"
			git checkout ${CURRENTBRANCH}
			git pull https://${USERNAME}:${PASSWORD}@${URL}
			bash ${BINPATH}/$(basename $0)
			exit
		fi
		AUTHOR=$(git show|grep "Author"|cut -d ":" -f2-)
		UPDATE=$(git show|grep "Date"|cut -d ":" -f2-)
		log "${URL},${SETBRANCH},${CURRENTBRANCH},${UPDATE},${AUTHOR}"
		echo "DETAIL,Git,${COUNT},${URL},${USERNAME},${PASSWORD},${CURRENTBRANCH}:${BRANCHLIST},${UPDATE},${AUTHOR}"
	fi
	COUNT=$((++COUNT))
done 3<${SYSTEMPATH}/wsdetail_Git
IFS=${THISIFS}
echo "DETAIL,Git,${COUNT},,,,master:master,no detail,no detail"
