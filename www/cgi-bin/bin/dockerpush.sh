#!/bin/bash
#
# Creates list of images on docker hub
source /var/www/cgi-bin/source/functions.sh

#Put master list in tmp
dockerlogin
docker push j2systems/docker:$1
docker logout
echo "SCRIPT END"

