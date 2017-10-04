#!/bin/bash
#
# Creates table from local images vs images on docker hub
IMAGES=tmp/images
rm -rf $IMAGES
while read REP TAG ID SIZE
do
        echo "$REP $TAG LOCAL $ID $SIZE" >> $IMAGES
done < <( docker images --format "{{.Repository}} {{.Tag}} {{.ID}} {{.Size}}" 2>&1)

while read TAG SIZE DATE
do
	if [[ $(grep -c "j2systems/docker $TAG" $IMAGES) -eq 0 ]]
	then
		echo "j2systems/docker $TAG REMOTE - $SIZE -" >> $IMAGES
	fi
done < tmp/dockerhub
