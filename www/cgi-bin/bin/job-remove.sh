#/bin/bash

# Reads waits 3 seconds and deletes the status of a job.  
# This stops js re-reading and executing "COMPLETE" routine

. /var/www/cgi-bin/tmp/globals
source ${SOURCEPATH}/functions.sh
log "remove $1 in 3 s..."
sleep 3s
log "remove $1 now"
rm -rf ${JOBSTATUSPATH}/$1
bash ${BINPATH}/docker-volprune.sh
