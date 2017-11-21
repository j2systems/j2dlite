#!/bin/bash
. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh

echo "DETAIL,Restart,REFRESH,System Restarting..."
echo "DETAIL,Restart,FIELDS,TEXT"
echo "DETAIL,Restart,STYLES,gray"
reboot

