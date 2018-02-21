#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
COMMONDIR=/var/lib/docker/volumes/common/_data
echo "DETAIL,GitLab,REFRESH,Username,Password,Token,ID,Group,Repo,Branch,User,Date,Remove:Add,Clone,Switch,Refresh,Unclone,ReSync"
echo "DETAIL,GitLab,FIELDS,INPUT,PASSWORD,INPUT,TD,TD,TD,TD,TD,TD,BUTTON,BUTTON,BUTTON,BUTTON,BUTTON,BUTTON"
echo "DETAIL,GitLab,STYLES,gray,gray,gray,gray,gray,gray,gray,gray,gray,red:green,yellow,yellow,green,red,blue"
THISIFS=$IFS
IFS=","
COUNT=1
while read USERNAME PASSWORD TOKEN ID GROUP REPO BRANCH BRANCHUSER BRANCHDATE
do
	if [[ ${USERNAME} != "" ]]
	then
		if [[ "${ID}" == "none" ]]
		then
			# seed wsdetail_GitLab
			sed -i "s/none/done/g" ${SYSTEMPATH}/wsdetail_GitLab
			echo "DETAIL,GitLab,FIELDS,TD,PASSWORD,TD,TD,TD,TD,TD,TD,TD,HIDDEN,HIDDEN,HIDDEN,HIDDEN,BUTTON"
			echo "DETAIL,GitLab,10000,${USERNAME},${PASSWORD},${TOKEN},Grabbing info from Gitlab.,Please wait ...,,,,"
			curl -k https://gitlab.j2interactive.com/api/v4/projects?private_token=${TOKEN}|jq '.[]|"\(.id) \(.path_with_namespace)"'|tr -d "\"" > ${TMPPATH}/gitlab
			bash ${BINPATH}/$(basename $0)
			IFS=" "
			while read ID THISREPO
			do
				NAMESPACE=$(echo ${THISREPO}|cut -d "/" -f1)
				REPONAME=$(echo ${THISREPO}|cut -d "/" -f2)
				echo "${USERNAME},${PASSWORD},${TOKEN},${ID},${NAMESPACE},${REPONAME},none,none,none" >> ${SYSTEMPATH}/wsdetail_GitLab
			done < ${TMPPATH}/gitlab 
			IFS=${THISIFS}
			echo "DETAIL,GitLab,FIELDS,TD,PASSWORD,TD,TD,TD,TD,TD,TD,TD,HIDDEN,HIDDEN,HIDDEN,HIDDEN,HIDDEN"
			echo "DETAIL,GitLab,10000,${USERNAME},${PASSWORD},${TOKEN},Grabbing Docker info.,Please wait ...,,,,"
			#Resync docker repos
			bash ${BINPATH}/docker-GitLab.sh
			bash ${BINPATH}/$(basename $0)
			exit
		
		fi
		
		if [[ "${COUNT}" == "1" ]]
		then
			#DISPLAY First line with Remove button
			if [[ "${ID}" != "done" ]]
			then
				log "First line of GitLab wrong.  Delete it!"
				rm ${SYSTEMPATH}/wsdetail_GitLab
				touch ${SYSTEMPATH}/wsdetail_GitLab
				bash ${BINPATH}/$(basename $0)			
				exit
			else
				echo "DETAIL,GitLab,FIELDS,TD,PASSWORD,TD,HIDDEN,HIDDEN,HIDDEN,HIDDEN,HIDDEN,HIDDEN,BUTTON,HIDDEN,HIDDEN,HIDDEN,HIDDEN,BUTTON"
				echo "DETAIL,GitLab,${COUNT},${USERNAME},${PASSWORD},${TOKEN},${ID},${GROUP},${REPO},-,-,-"
				echo "DETAIL,GitLab,FIELDS,HIDDEN,HIDDEN,HIDDEN,TD,TD,TD,TD,TD,TD,HIDDEN,BUTTON,HIDDEN,HIDDEN,HIDDEN,HIDDEN"		
			fi
			COUNT=$((++COUNT))
		else
			#Display rest of Data.
			#If git not cloned, offer clone button else offer switch and update buttons
			
			if [[ -d ${COMMONDIR}/GitLab/${GROUP}/${REPO} ]]
			then
				echo "DETAIL,GitLab,FIELDS,HIDDEN,HIDDEN,HIDDEN,TD,TD,TD,SELECT,TD,TD,HIDDEN,HIDDEN,BUTTON,BUTTON,BUTTON,HIDDEN"
				REPODIR=$(find ${COMMONDIR}/GitLab/${GROUP}/${REPO} -maxdepth 1 -mindepth 1 -type d -name .git|rev|cut -d "/" -f2-|rev)
				if [[ "${REPODIR}" != "" ]]
				then
					HERE=$(pwd)
					cd ${REPODIR}
					unset BRANCHLIST
					for NEWBRANCH in $(git branch -a|grep remotes|grep -v "HEAD"|cut -d "/" -f3|cut -d " " -f1|tr "\n" " "|sed 's/ *$//')
					do

						if [[ "${BRANCHLIST}" == "" ]]
						then
							BRANCHLIST=${NEWBRANCH}
						else
							BRANCHLIST=$(echo "${BRANCHLIST} ${NEWBRANCH}")
						fi
					done
					unset SETBRANCH
					SETBRANCH=$(git branch -a|grep "*"|cut -d "*" -f2|tr -d " ")
					if [[ "${SETBRANCH}" != "${BRANCH}" ]]
					then
						# SWITCH BRANCH
						log "SWITCH BRANCH! - BRANCH= ${BRANCH} SETBRANCH=${SETBRANCH} ref ${ID}"
						git checkout ${BRANCH}
					fi
					AUTHOR=$(git show|grep "Author"|head -n 1|cut -d ":" -f2-)
					UPDATE=$(git show|grep "Date"|head -n 1|cut -d ":" -f2-) 
					cd ${HERE} 
					echo "DETAIL,GitLab,${COUNT},${USERNAME},${PASSWORD},${TOKEN},${ID},${GROUP},${REPO},${BRANCH}:${BRANCHLIST},${AUTHOR},${UPDATE}"
				fi
			else
				echo "DETAIL,GitLab,FIELDS,HIDDEN,HIDDEN,HIDDEN,TD,TD,TD,TD,TD,TD,HIDDEN,BUTTON,HIDDEN,HIDDEN,HIDDEN,HIDDEN"
				echo "DETAIL,GitLab,${COUNT},${USERNAME},${PASSWORD},${TOKEN},${ID},${GROUP},${REPO},-,-,-"
			fi
			COUNT=$((++COUNT))
		fi
	fi
done < ${SYSTEMPATH}/wsdetail_GitLab
if [[ ${COUNT} -eq 1 ]]
then
	echo "DETAIL,GitLab,FIELDS,INPUT,PASSWORD,INPUT,TD,TD,TD,TD,TD,TD,BUTTON,HIDDEN,HIDDEN,HIDDEN,HIDDEN"
	echo "DETAIL,GitLab,${COUNT},,,,none,none,none,none,none,none"

fi
IFS=$THISIFS
