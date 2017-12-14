#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

echo "DETAIL,SHUTDOWN,REFRESH,Powering off..."
echo "DETAIL,SHUTDOWN,FIELDS,TEXT"
echo "DETAIL,SHUTDOWN,STYLES,gray"
poweroff
