#!/bin/bash
# $1=username,$2=password,$3=token,$4=id,$5=group,$6=repo


. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
COMMONDIR=/var/lib/docker/volumes/common/_data
export HOME=${COMMONDIR}
cd ${COMMONDIR}/GitLab/$5/$6
git config --global http.sslVerify false
git config --global user.email "$1@j2interactive.com"
log "Execute git pull https://$1:$2@gitlab.j2interactive.com/$5/$6 at $(pwd)"
git pull https://$1:$2@gitlab.j2interactive.com/$5/$6

