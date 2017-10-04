#!/bin/bash
#
# Creates table from zfs list

OUTPUTDIR=/var/www/cgi-bin/tmp

#Clear current info

for ZFSOUT in zfsstats zfspools dockervols zfsusage
do 
	[[ -f $OUTPUTDIR/$ZFSOUT ]] && rm -rf $OUTPUTDIR/$ZFSOUT
	touch $OUTPUTDIR/$ZFSOUT && chown :apache $OUTPUTDIR/$ZFSOUT
done

zfs get -o name,value -Hp used > $OUTPUTDIR/zfsstats
zpool list > $OUTPUTDIR/zfspools
docker inspect --format='{{json .GraphDriver.Data.Dataset}} {{.RepoTags}}' $(docker images -qa)|tr -d "\"[]" > $OUTPUTDIR/dockervols
docker inspect --format='{{json .GraphDriver.Data.Dataset}} {{.Name}}' $(docker ps -qa)|tr -d "\"[]"|sed "s, /, ,g" >> $OUTPUTDIR/dockervols

while read NAME USED
do
        unset CROSSREF
	unset STATUS
        CROSSREF=$(grep "$NAME " $OUTPUTDIR/dockervols|cut -d " " -f2)
        if [[ "$CROSSREF" != "" ]]
        then
                NAME=$CROSSREF
		echo "$NAME $USED" >> $OUTPUTDIR/zfsusage
        else
                if [[ $(echo $NAME|grep -c "@") -eq 0 ]]
                then
			if [[ $(echo $NAME|grep -c "-") -eq 1 ]]
			then
				THISREF=$(echo $NAME|cut -d "-" -f1)
				CROSSREF=$(grep "$THISREF" $OUTPUTDIR/dockervols|cut -d " " -f2)
				echo "$CROSSREF-base $USED" >> $OUTPUTDIR/zfsusage
			else
			 	[[ $(echo $NAME|grep -c "rpool/ROOT/") -ne 0 ]] && echo "(Reference-volume) $USED" >> $OUTPUTDIR/zfsusage
			fi
                        unset THISREF
                        #THISREF=$(echo $NAME|cut -d "@" -f1)
                        #CROSSREF=$(grep "$THISREF" $OUTPUTDIR/dockervols|cut -d " " -f2)
                        #[[ "$CROSSREF" != "" ]] && NAME="(${CROSSREF}-base)"
			
		#else
			#[[ $(echo $NAME|grep -c "rpool/ROOT/") -ne 0 ]] && NAME="Other"
                fi
		
        fi


done < $OUTPUTDIR/zfsstats

