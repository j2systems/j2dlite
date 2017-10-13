#/bin/bash
#Remember - pass tokens in as IP, "command".  Note the inverted commas

. /var/www/cgi-bin/tmp/globals
FILENAME="$(date +"%Y%m%d%H%M%S")$((RANDOM))"
IP=$1
REQUEST="$2"
echo "${IP},${REQUEST}" > ${JOBREQUESTPATH}/${FILENAME}
