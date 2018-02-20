#!/bin/bash
# $1=username,$2=password,$3=token,$4=id,$5=group,$6=repo


. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
COMMONDIR=/var/lib/docker/volumes/common/_data/GitLab
sed -i "s/$1,$2,$3,$4,$5,$6,$7/$1,$2,$3,$4,$5,$6,none/g" ${SYSTEMPATH}/wsdetail_GitLab
log "rm -rf ${COMMONDIR}/$5/$6"
rm -rf ${COMMONDIR}/$5/$6
