#!/bin/bash
# $1=username,$2=password,$3=token,$4=id,$5=group,$6=repo


. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
COMMONDIR=/var/lib/docker/volumes/common/_data
export HOME=${COMMONDIR}
[[ ! -d ${COMMONDIR}/GitLab/$5 ]] && mkdir -p ${COMMONDIR}/GitLab/$5
cd ${COMMONDIR}/GitLab/$5/
git config --global http.sslVerify false
git clone https://$1:$2@gitlab.j2interactive.com/$5/$6.git
SETBRANCH=$(git branch -a|grep "*"|cut -d "*" -f2|tr -d " ")
sed -i "s/$1,$2,$3,$4,$5,$6,none/$1,$2,$3,$4,$5,$6,${SETBRANCH}/g" ${SYSTEMPATH}/wsdetail_GitLab

